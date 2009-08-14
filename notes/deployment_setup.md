# Deploying with Capistrano and Git/Github
Make sure you have the capistrano gem installed on your local machine and a github account.

## Install gems and capify
    sudo gem install capistrano --no-ri --no-rdoc
    sudo gem install capistrano-ext --no-ri --no-rdoc

    capify .

## Setup
After running capify and setting up deploy.rb you can check your connection settings by running:

    cap shell

## Create directory structure

    cap deploy:setup

The previous command might create the directories under the root user. Change that by ssh'ing into
the server and change the owner.

    sudo chown -R deploy:deploy master/

## Check dependencies
    cap deploy:check

Fix any errors this might reveal.

## Database Initialization
Make sure database is installed and correctly setup. I create database.yml in the shared directory
which then gets symlinked on each deploy. This is to keep db credentials out of the repo and
private.

    cd to capistrano shared directory
    mkdir config
    vi database.yml
    [insert db config]

## Add public key to github repo
If your repo is private you'll need to
[add your public key](http://github.com/guides/providing-your-ssh-key#linux) so you can pull in the
code.

You might have to clone the repo one time on the server to cache github.com to known_hosts.

## Pushing the Code, Kicking the Tires
This will copy your source code to the server, and update the “current” symlink to point to it, but
it doesn’t actually try to start your application layer.

If any of that fails, you might need to look closely at the output to determine what went wrong.
Maybe it was a permissions error? Maybe it can’t find the svn executable? A common error at this
point is when subversion is unable to talk to the repository server, due perhaps to a missing public
key on the server. Most of those things should have been caught at the deploy:check stage, but it
seems like there are always little edge cases that slip through the cracks. Fix those up and keep
trying “deploy:update” until it succeeds.

    cap deploy:update

Load schema. Warning: this is destructive.

    cd to current/
    rake app:db:reset RAILS_ENV=production

Once that’s done, we can test to see that our application will actually load by starting up a
console instance:

    script/console production
    >> app.get("/")

That will return the HTTP status code. If it returns 200 or 302 (or any other 2xx or 3xx code, or
even 4xx if you haven’t configured the ”/” url for your application), you’re probably set. If it
returns something in the 500’s, you’ll want to check your log/production.log and see why it blew up.

Now you can try to start up the app.

    cap deploy
