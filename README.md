# potion

Potion is a single application to configure a system, like Puppet or Chef,
but minimalist.

## Usage

There are two ways to use potion:

1. You can use `potion` to run a recipe. A recipe is a script which contains
   the description of the configuration that you want to apply.
2. You can use potion to create a standalone autoexecutable recipe, so you
   don't need potion to run a potion file.


### Using potion to run a recipe

~~~~ {.bash}
potion run Potionfile Otherrecipe.potion
~~~~

The recipe is any bash script which can contain a number of specific
funtions, listed below in API Reference.

### Using potion to create a self-executable recipe

~~~~~ {.bash}
potion create Potionfile > recipe.sh
~~~~~

### Using potion to run a local recipe in remote host
~~~~~ {.bash}
potion -q create Potionfile | ssh -tt hostname
~~~~~

### Using potion with remote recipes

~~~~~ {.bash}
potion run https://miremotehost/remoterecipe.potion
~~~~~

Or more complex example with ssh and git:

~~~~~ {.bash}
potion run ssh+git://myremoterepohost/mirepo.git
~~~~~

When you point to a repo, a file called ``init.potion`` in the root dir of
the repo is loaded automatically, as potion starting point.

### Using default recipes

~~~~~ {.bash}
export POTION\_DEFAULT_SOURCE="ssh+git://myremoterepohost/mirepo.git"
potion run
~~~~~


## Using potion to run periodically

Potion does not support daemon mode, but you can use systemd timers or cron
jobs to run potion every hour or when you prefer. Please note that potion
requires some environment variables like ``HOME``. Is a good practice tu run
potion with sudo as unprivileged user, for example:

~~~~~ {.bash}
$ id
uid=1000(user) gid=1000(user) groups=1000(user)
$ sudo -i potion run script.potion
~~~~~


## Writing recipes

Potion recipes are, in fact, bash scripts, so any thing that you can create
with a bash script could be used in recipe, nevertheless we recommend you to
use potion API to more common situations, and create new modules over them.
Recipes are evaluated in order, but you parallelize actions using context
(read more below).

### Contexts

A context is a new process running by potion to perform some task in
parallel. You can configure context with the following syntax in the Potion
file:

~~~~~~ {.bash}
@context1
{
  # do some actions
}

@context2
{
  # do other actions
}
~~~~~~

In this example we create two context which will be running in parallel in
the host.

### Artifacts

An artifact is a set of files which should be included in the potion file and
deployed by Potion application. You can think an artifact like a template
for file. You can use artifacts like any other file, in the form:

~~~~~ {.bash}
file::present /etc/config.json \
  data="artifact://config.json"
~~~~~

This code will create (if doesn't exist yet) a fil in `/etc/config.json`,
which content is generated from artifact called `config.json`. The artifacts
directory must be specified by command like when called potion, like the
following example:

~~~~~ {.bash}
potion run -a ./artifacts_dir Potionfile
~~~~~

If you generate a self-executable potion file, the artifacts will be
included in the script.

Instead of `artifact://` url, you can use `artifact+eval://` url, which
allows you to expand variables inside the artifact file. You can use normal
`$variable` form, or even run more complex like `$(if $var; then echo value;
fi)`.

You can also load artifacts programatically from the potion recipe, using
``artifact::load``:

~~~~~ {.bash}
artifact::load ./path/to/artifactsdir
~~~~~

## Secrets

Secrets are intented to keep some variables of your config in secret. Potion
will add secret variables using module ``secret``, documented in the API.
The secret file is just another potion file which contains ``secret::add``
commands, which define secret values in plain.

There are three different ways to use secrets:

1. Keep you secret file out of the recipes, and copy on each host
   individually. The run potion with `-s` (`--secret`) flag pointing to the
   secret file.

2. Use symmetric encryption (recommended method). Potion will read
   a passphrase from `/etc/potion.key` (or where ``SECRET_MASTERKEY``
   environment variable defines) and use that passphrase to decrypt the secret
   file (using AES256 via openssl).

3. Using asymetric encyption via GnuPG, using different keyfiles for each
   host. This is the most secure way, but hard to maintain.

Recomended option is to set a plain `secret.potion` file outside your
recipes repository and encrypt it with:

~~~~~ {.bash}
openssl enc -e -a -aes256 -in secret.potion -out secret.potion.aes
~~~~~

And keep `secret.potion.aes` (encrypted file) under version control
system (The `-a` flag in openssl indicates to encode the file using base64,
which is used by potion too). This methid provide a reasonable security and
a goo way to manage the secrets from central repository.

Of course, you can load secrets programatically, for example:

~~~~~ {.bash}
secret::load "crypt+file://$PWD/secrets.potion.aes"
~~~~~

This example using openssl encrypt (`crypt`) method to decrupt secrets file.
In API documentation, under module `secret` you can see different load
formats, including plain and gpg ones.

## Including other potion files

You can split your config in different modules, and you can load them from
the starting potion file (`init.potion` if you are loading recipes from
repository). See the `include` module to learn in which ways you can include
other modules, but in general you will use the following:

~~~~~ {.bash}
include::path ./modules/\*.potion
~~~~~

## Testing changes

Before to apply changes, you probably want to test the changes, to do that
you can run potion with `--pretend` flag. If you are running and
self-executable potion, you can use the environment variable `$PRETEND=true`
to ensure that the potion just pretending instead on real running.

## Bonus: How structure your recipes

There is no unique way to structure your recipes, depends of how complex
your configuration is, but in general, this is a good approach:

1. Put your artifacts under `artifacts/` directory
2. Create modules under `modules/` to configure some software (i.e. module
   `nginx`). Module should have a `::present`, `::exists` and `::absent`
   functions.
3. Create modules under `profiles/` to help you to group core actions. For
   example profile `webserver` will use module `nginx` and other to
   configure a webserver.
4. Create modules under `roles/` to group profiles. For example `frontend`
   role will use webserver and others to configure what a frontend server
   is.
5. Finally modules under `nodes/` and named like FQDN of the node, will
   include roles that defined those server.

Of course, you can follow any other approach that be convenient for you,
this is just a recommendation.
