# kakashy

Copy any web page, top to bottom, into one tall PNG. Like the Sharingan: it copies what it sees.

Local only. No cloud screenshot API, no API key, no LLM. Python standard library plus one small Swift helper.

## Why you might want this

Full-page screenshot services (the `curl -X POST .../screenshots` kind) cannot see pages behind a login.
They fetch the URL from their own servers, so they get the login wall, not your page.

You also may not want to send a private page to a third party at all.

Common cases:

- Save a long ChatGPT, Claude, or support-chat conversation as one image.
- Capture an internal dashboard, wiki page, or admin screen that needs your session.
- Keep a record of a page as it looked today.

Safari's own tools do not solve this well:

- Safari has no built-in full-page PNG (only PDF or Reader).
- Chat apps scroll inside a nested container, not the page. A normal "capture full page" misses most of the content.

kakashy finds the real scroll container, scrolls it, captures each screen, and stitches the frames.

## How it works

1. Opens its own new Safari window at your URL. Your cookies apply, so you are already logged in.
2. Finds the element that really scrolls and loads lazy content by scrolling to the top until the height settles.
3. Hides sticky headers and anything you pass with `--hide`.
4. Scrolls in steps and runs `screencapture` on that one window each time.
5. Crops browser chrome and the sidebar, and stitches the frames into one PNG.
6. Closes only the window it opened. Your own tabs are never touched.

## Requirements

- macOS with Safari
- Python 3 (standard library only)
- Xcode command line tools (`xcode-select --install`), for `swiftc`

## Install

```sh
git clone https://github.com/joshuascottpaul/kakashy.git ~/GitHub/kakashy
ln -s ~/GitHub/kakashy/kakashy ~/bin/kakashy    # any folder on your PATH
```

The first run compiles the stitcher into `~/.cache/kakashy`.

One-time macOS and Safari settings:

1. Safari > Settings > Advanced: turn on "Show features for web developers".
2. Develop menu > Allow JavaScript from Apple Events.
3. System Settings > Privacy & Security > Automation: allow your terminal app to control Safari.
4. System Settings > Privacy & Security > Screen Recording: allow your terminal app.

## Use

```sh
kakashy https://example.com page.png
```

Hide a chat composer or any other fixed element with a CSS selector:

```sh
kakashy https://chatgpt.com/c/<id> chat.png --hide 'form:has([contenteditable=true],textarea)'
```

Options:

- `--hide CSS` hides matching elements before capture. Repeat it for more than one.
- `--width N` sets the window width in points. Default 1300.
- `--keep-frames` keeps the raw per-screen frames for debugging.

The output is Retina resolution, so a long page makes a large PNG (a 25,000 point page is about 50,000 pixels tall).

## Limits

- Your Mac must stay awake and Safari must stay visible while it runs. It captures the window, so do not cover it.
- Pages that virtualize their content (drop items that scroll out of view) can come out with gaps.
- Private browsing windows cannot be scripted.
- macOS only.

## License

MIT. See `LICENSE`.
