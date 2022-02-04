# smashgg-social-finder

Get the social media connections for the top 8 players in a bracket.

# Motivation

Quickly creating top 8 graphics! And DevDogg.

# What is a slug?

For a tournament that looks like this:
```
https://smash.gg/tournament/meta-knight-fight-night/event/project-singles/entrant/9184648
```

The slug is this (after `/tournament/` in the URL path):

```
meta-knight-fight-night
```

# How do I get a key?

> In order to access smash.gg’s API, you must use an authentication token. These tokens can be created from the Developer Settings page in your account settings.

Visit https://smash.gg/admin/profile/developer when logged into your smash.gg account.

There's an illustrated tutorial available:
* https://developer.smash.gg/docs/authentication

Unforuntately, there's no support for guest keys available on their public API. The private API does not require a token, but is not available due to CORS restrictions (?).

# Building

This code is written in Elm.

``` sh
elm make src/Main.elm --optimize --output=elm.js
```

Deploy in the same directory as:
* `index.html`
* `style.css`

# TODO

* Link to smash.gg profile in output
* Link to social media accounts in output
* Include decoded standing information in output
* Document how to grab a GraphQL Smash.gg API Key on main page
* Deploy
