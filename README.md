# Capistrano Statistics

In order to better support Capistrano, this gem (and the server, and dashboard
included) is intended to collect (when enabled, via the prompt) metrics about
how Capistrano is used, it collects a line which looks something like this:

    1|2014-07-16T22:56:30+02:00|2.1.1|x86_64-darwin13.0|2.15.5|90f7c671
    │ │                         │     │                 │      │
    │ │                         │     │                 │      └── Anon project UUID (see below)
    │ │                         │     │                 │
    │ │                         │     │                 └── Capistrano version.
    │ │                         │     │
    │ │                         │     └── Ruby platform identifier RUBY_PLATFORM.
    │ │                         │
    │ │                         └── Ruby interpreter version, RUBY_VERSION.
    │ │
    │ └── Current datestamp according to your machine ISO8601 formatted.
    │
    └── Protocol number, reserved incase we change the format some day.

The "Anon project UUID" is the first 8 bytes of the hex encoded MD5 sum of your
Git "origin" server, if you are using Git.

This allows us to track an approximate value for "how many projects use
Capistrano", versus tracking individual executions of projects. i.e if you work
on your project together with one or more other people, and you deploy three
times during a day, for that day we will register three deploys, but a single
"unique deploy".

If you are not using Git, or do not have a "remote" defined, this field will
read `not-git`. We may expand in future stats versions to also enumerate the
subversion, mercurial, etc hosts, but `not-git` will help us track how
important each of the other source control tools might be to support.

## Example Projects

Two very thin skeleton projects demonstrate how to use the metrics collection
with both version two and three for testing purposes:

    $ cd ./examples/capistrano-2.x/
    $ bundle
    $ CAPISTRANO_METRICS=127.0.0.1:1200 bundle exec cap default
      triggering start callbacks for `default'
      * 2014-07-16 23:38:24 executing `metrics:collect'
      * 2014-07-16 23:38:24 executing `default'
      Done
    $ cd ./examples/capistrano-3.x/
    $ bundle
    $ CAPISTRANO_METRICS=127.0.0.1:1200 bundle exec cap default --trace
      ** Invoke metrics:collect (first_time)
      ** Execute metrics:collect
      ** Execute deploy:starting
      Done
      ** Execute default
      ** Invoke load:defaults (first_time)
      ** Execute load:defaults

## Disable Statistics Collection

The initial statistics collection prompt may break your automated build or
deployment systems. If you would like to disable the collection you can create
a .capstrano folder in your project and a file within called metrics with the
content "false"

```
cd <project directory>
mkdir .capistrano
echo "false" > .capistrano/metrics
```
