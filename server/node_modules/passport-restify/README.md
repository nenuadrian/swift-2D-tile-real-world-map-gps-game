[![passport banner](http://cdn.auth0.com/img/passport-banner-github.png)](http://passportjs.org)

# Passport

[![Build](https://travis-ci.org/jameswomack/passport-restify.svg?branch=master)](https://travis-ci.org/jameswomack/passport-restify)
[![Coverage](https://coveralls.io/repos/jameswomack/passport-restify/badge.svg?branch=master)](https://coveralls.io/r/jameswomack/passport-restify)
[![Quality](https://codeclimate.com/github/jameswomack/passport-restify/badges/gpa.svg)](https://codeclimate.com/github/jameswomack/passport-restify)
[![Dependencies](https://david-dm.org/jameswomack/passport-restify.svg)](https://david-dm.org/jameswomack/passport-restify)
[![Tips](https://img.shields.io/gratipay/jaredhanson.svg)](https://gratipay.com/jaredhanson/)


Passport Restify is [Restify](https://github.com/restify/node-restify)-compatible authentication
middleware for [Node.js](http://nodejs.org/).

Passport's sole purpose is to authenticate requests, which it does through an
extensible set of plugins known as _strategies_.  Passport does not mount
routes or assume any particular database schema, which maximizes flexibility and
allows application-level decisions to be made by the developer.  The API is
simple: you provide Passport a request to authenticate, and Passport provides
hooks for controlling what occurs when authentication succeeds or fails.

## Install

    $ npm install passport-restify

## Usage

#### Strategies

Passport uses the concept of strategies to authenticate requests.  Strategies
can range from verifying username and password credentials, delegated
authentication using [OAuth](http://oauth.net/) (for example, via [Facebook](http://www.facebook.com/)
or [Twitter](http://twitter.com/)), or federated authentication using [OpenID](http://openid.net/).

Before authenticating requests, the strategy (or strategies) used by an
application must be configured.

    passport.use(new LocalStrategy(
      function(username, password, done) {
        User.findOne({ username: username }, function (err, user) {
          if (err) { return done(err); }
          if (!user) { return done(null, false); }
          if (!user.verifyPassword(password)) { return done(null, false); }
          return done(null, user);
        });
      }
    ));

There are 300+ strategies. Find the ones you want at: [passportjs.org](http://passportjs.org)

#### Sessions

Passport will maintain persistent login sessions.  In order for persistent
sessions to work, the authenticated user must be serialized to the session, and
deserialized when subsequent requests are made.

Passport does not impose any restrictions on how your user records are stored.
Instead, you provide functions to Passport which implements the necessary
serialization and deserialization logic.  In a typical application, this will be
as simple as serializing the user ID, and finding the user by ID when
deserializing.

    passport.serializeUser(function(user, done) {
      done(null, user.id);
    });

    passport.deserializeUser(function(id, done) {
      User.findById(id, function (err, user) {
        done(err, user);
      });
    });


#### Authenticate Requests

Passport provides an `authenticate()` function, which is used as route
middleware to authenticate requests.

    app.post('/login', 
      passport.authenticate('local', { failureRedirect: '/login' }),
      function(req, res) {
        res.redirect('/');
      });

## Strategies

Passport has a comprehensive set of **over 300** authentication strategies
covering social networking, enterprise integration, API services, and more.

## Search all strategies

There is a **Strategy Search** at [passportjs.org](http://passportjs.org)

The following table lists commonly used strategies:

|Strategy                                                       | Protocol                 |Developer                                       |
|---------------------------------------------------------------|--------------------------|------------------------------------------------|
|[Local](https://github.com/jameswomack/passport-restify-local)         | HTML form                |[Jared Hanson](https://github.com/jaredhanson)  |
|[OpenID](https://github.com/jameswomack/passport-restify-openid)       | OpenID                   |[Jared Hanson](https://github.com/jaredhanson)  |
|[BrowserID](https://github.com/jameswomack/passport-restify-browserid) | BrowserID                |[Jared Hanson](https://github.com/jaredhanson)  |
|[Facebook](https://github.com/jameswomack/passport-restify-facebook)   | OAuth 2.0                |[Jared Hanson](https://github.com/jaredhanson)  |
|[Google](https://github.com/jameswomack/passport-restify-google)       | OpenID                   |[Jared Hanson](https://github.com/jaredhanson)  |
|[Google](https://github.com/jameswomack/passport-restify-google-oauth) | OAuth / OAuth 2.0        |[Jared Hanson](https://github.com/jaredhanson)  |
|[Twitter](https://github.com/jameswomack/passport-restify-twitter)     | OAuth                    |[Jared Hanson](https://github.com/jaredhanson)  |

## Examples

- For a complete, working example, refer to the [login example](https://github.com/jameswomack/passport-restify-local/tree/master/examples/login)
included in [passport-local](https://github.com/jameswomack/passport-restify-local).
- **Local Strategy**: Refer to the following tutorials for setting up user authentication via LocalStrategy (`passport-local`)
    - Express v3x - [Tutorial](http://mherman.org/blog/2013/11/11/user-authentication-with-passport-dot-js/) / [working example](https://github.com/mjhea0/passport-local)
    - Express v4x - [Tutorial](http://mherman.org/blog/2015/01/31/local-authentication-with-passport-and-express-4/) / [working example](https://github.com/mjhea0/passport-local-express4)
- **Social Authentication**: Refer to this [tutorial](http://mherman.org/blog/2013/11/10/social-authentication-with-passport-dot-js/) for setting up various social authentication strategies, including a working example found on this [repo](https://github.com/mjhea0/passport-examples).

## Related Modules

- [Locomotive](https://github.com/jaredhanson/locomotive) — Powerful MVC web framework
- [OAuthorize](https://github.com/jaredhanson/oauthorize) — OAuth service provider toolkit
- [OAuth2orize](https://github.com/jaredhanson/oauth2orize) — OAuth 2.0 authorization server toolkit
- [connect-ensure-login](https://github.com/jaredhanson/connect-ensure-login)  — middleware to ensure login sessions

The [modules](https://github.com/jameswomack/passport-restify/wiki/Modules) page on the
[wiki](https://github.com/jameswomack/passport-restify/wiki) lists other useful modules
that build upon or integrate with Passport.

## Tests

    $ npm install
    $ make test

## Credits

  - [Jared Hanson](http://github.com/jaredhanson)

## Supporters

This project is supported by ![](http://passportjs.org/images/supported_logo.svg) [Auth0](https://auth0.com) 

## License

[The MIT License](http://opensource.org/licenses/MIT)

Copyright (c) 2011-2015 Jared Hanson <[http://jaredhanson.net/](http://jaredhanson.net/)>

