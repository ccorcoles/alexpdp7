# Don't fear the Emacs

If you are here, you are probably thinking about adopting Emacs as your editor.
Perhaps you are facing analysis paralysis, wondering what's the best way to do it.

Just do it!
It's a bit alien at first, but I didn't need much time to do all my editing in Emacs.
I haven't learnt Emacs Lisp and I haven't adopted any large configuration package.

[My `emacs.el` right now is 80 lines](https://github.com/alexpdp7/alexpdp7/blob/811f60a331da44c9621d771ccc34ee0c0555080e/emacs/emacs.el).
Perhaps when you read this, my current config will be much bigger..
But I'm definitely happy today with my 80-line config.

You can start without a configuration.
Whenever you can't do something, search Internet.
You will quickly learn the hotkeys you need the most.
Once you can search, undo, cut, copy, and paste, you can take your time with the rest.
Don't avoid the menus.
Sometimes it's just easier to hit F10 and find something in the menus.
You can also M-x to execute commands, like `indent-region`.

When you get to the point where you really need to add packages, I do recommend you use [straight.el](https://github.com/radian-software/straight.el), it makes installing packages easy.
Maybe it has some drawbacks, but with straight.el, I've been able to create a configuration that I feel is productive.
(Although it seems to have some issues with corporate firewalls. But I added comments about solving that.)

Some of the stuff in my `emacs.el` is maybe not critical, like Helm and Projectile.
I really like Projectile, but often I just run `emacs $file` in a new terminal tab.
It's easy, and you don't need to learn a ton of window/buffer/etc. management.
(Be sure to check [emacs.bash](https://github.com/alexpdp7/alexpdp7/blob/master/emacs/emacs.bash) for something you can source in your bash to prevent frequent Emacs startups.)

Many other stuff is support for things I do: AsciiDoc, Vale, Rust, Python, Java, YAML, Ansible, Puppet.
You probably need other plugins, and maybe you don't need them right now.

Maybe try out some of the large configurations, to learn what fancy stuff is available and add it as you become comfortable with the previous thing you configured.