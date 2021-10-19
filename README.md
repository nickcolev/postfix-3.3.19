# postfix-3.3.19
Tiny Core Linux flavour

Target older Tiny Core Linux (TCL) versions, e.g. 6.x.
Newer postfix require OpenSSL that is not available there.
Older versions might have security issues, though.

## BUILD

Clone and go to `postfix-3.3.19` directory. Then

```./tcl```

for usage. Use step-by-step, or do everything with the options at your pace.

## CONFIGURATION

Configuration is **not** included in the generated `postfix.tcz`.
Setup configuration in `/etc/postfix/` according to [Postfix documentation](http://www.postfix.org/postconf.5.html),
customize it, and take care to [make it persistent](http://wiki.tinycorelinux.net/wiki:start#persistence).

## REFERENCES
### Postfix
* [Official site](http://www.postfix.org/)
* [Configuration](http://www.postfix.org/postconf.5.html)
* [Wikipedia](https://en.wikipedia.org/wiki/Postfix_(software))
### Tiny Core Linux (TCL)
* [Official site](http://www.tinycorelinux.net/)
* [Custom extensions](http://wiki.tinycorelinux.net/wiki:extension_for_settings)
* [Creating extensions](http://wiki.tinycorelinux.net/wiki:creating_extensions)
