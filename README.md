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
potion run Potionfile
~~~~

The recipe is any bash script which can contain a number of specific
funtions, listed below in API Reference.

### Using potion to create a self-executable recipe

~~~~~ {.bash}
potion create Potionfile > recipe.sh
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
file::present /etc/config.json \\
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

## Testing changes

Before to apply changes, you probably want to test the changes, to do that
you can run potion with `--pretend` flag. If you are running and
self-executable potion, you can use the environment variable `$PRETEND=true`
to ensure that the potion just pretending instead on real running.
