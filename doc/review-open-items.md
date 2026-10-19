# Design review: open items

Temporary list to come back to. Started 2026-10-19 at the end of the events index pass; delete when it is empty. The page-by-page notes are in `review-2026-10-19.md`.

## To test

- [ ] Newsletter sign-up, success path. Submit the dev footer with a real address: expect "Thanks! Check your inbox for a link to confirm." in place of the box and a Ghost email from gfsc.community. Then remove the member in Ghost admin if unwanted. (Error path verified 2026-10-19.)
- [ ] Index card tops on the iPad after the day number nudge (-0.25rem).

## Need a screenshot from the iPad

- [ ] "Created by" logos in the footer looking off-centre vertically (Chrome and WebKit both measure them level).

## Decisions

- [ ] Date picker on iPad and Mac: Safari's own small popover, or a TD-styled JavaScript calendar (mock first).

## Core follow-ups

- [ ] Bullet N+1 on /partners and /news: "USE eager loading detected ... .includes([:partners])" (Site partners). For the perf audit (#3519).
- [ ] `/events` runs 174 queries (116 cached). Perf audit.

## Before merging

- [ ] Theme PR #10: revert the CI pin to core's `td/final-design-slots` once core #3528 is merged; core first, then theme release (version bump + tag + core `extension:bump`).

## Housekeeping

- [ ] Kim: reset the iPhone Auto-Lock.
- [ ] Dev server and Browsersync are left running on the Mac; kill with `pkill -9 -f "rails|puma|foreman|browser-sync"` when done.
