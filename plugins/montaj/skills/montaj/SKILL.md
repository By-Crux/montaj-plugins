---
name: montaj
description: "Use for any Montaj or video editing request: projects, cuts, captions, overlays, renders. Says which Montaj tool performs each operation. Load it before calling any Montaj tool."
---

If the tools offer `get_skill`, call `get_skill("mcp")` first for the current version of this skill.

# Montaj from a connected AI app

You reach Montaj through the tools of the Montaj connection in this app. This skill says which tool performs each operation the other Montaj skills name. When another skill tells you to run a program, call a web address, or read or write a project's files on disk directly, do the matching thing from this skill instead. Those instructions are for other setups.

The Montaj app must be open on the user's computer. If a tool says Montaj isn't running, ask the user to open the Montaj app, then try again.

## Which tool does what

| When a skill says | Use |
|---|---|
| run step `<name>` with `<args>` | `run_step` with `name` and `params`. `list_steps` lists the steps; `get_step` with a step's `name` gives its parameters. |
| read the project | `get_project` with the project id |
| save the project (delta) | `save_project` with the project id and `changes` (see Saving) |
| write a file `<path>` `<contents>` | `write_file` with an absolute path. For an overlay component, use `write_project_overlay` instead. |
| read a file `<path>` | `read_file` with the absolute path. For an image, this shows you the picture. |
| list a project's files | `list_files` with the project id, and `folder` for a folder inside it. It says which files are already sources; add another with `import_media` and the project. |
| log `<message>` | `post_progress` with the project id and `message`, one short line. It shows live in the Montaj window. Also say it to the user in this chat. |
| render the project to a video file | `render_project` with the project id, then `get_render_status` (see Looking at frames) |
| read the workflow | `get_workflow` with the workflow name |
| put a Hub template's files into a project | `install_workflow_assets` with the project id and the workflow name |
| make a clip of a Clips project (`app/find_clips`) | `create_project` with `clip_of` (the Clips project's id), `clip` (the cut clip), a name and a prompt |
| link a project to its post in Plan | `update_pipeline_item` with `project_id`, or `pipeline_item_id` on `create_project` for a clip |
| the user's tasks (Pipeline, Today) | `list_tasks`, `add_task`, `complete_task`. Never deleted: that is the user's. Add one only for a follow-up they asked for or one clear next step, never many at once. |
| schedule a finished post through the user's Buffer or Metricool (Montaj Hub) | `schedule_post` with the post's id and `action` (`schedule`, `reschedule`, `cancel`), `platforms` or `channels`, and `scheduled_date` and `scheduled_time` (the user's local time). Export the post first. Schedule only what the user asked for in this chat, then tell them which accounts and when: a scheduled post goes public by itself at its time. |
| remove a Clips project's long video once its clips exist | `remove_clips_source` |
| use a profile's Brand Kit (Montaj Studio) | `get_profile_kit`, optionally with `profile` from `list_profiles`. It returns the Brand Kit's folders (each with its icon) with their files, and its top-level files, each with its name and local path, and the team animations (name, group, jsxPath, description). Refer to folders and files by name. |

Run every step with `run_step`, including `probe`, `snapshot`, `transcribe` and `sample_frame`. Don't look for a tool named after a step. `run_step` takes the parameter names from `get_step` and uses the service keys the user connected in the app.

To cut speech by its words, run `speech_text` with the project id, edit the text it returns, save it with `write_file` to the same path, then run `speech_edit` with `project` and `text` (that path), first with `preview`. Load the `speech-edit` skill with `get_skill` before you start.

An entry in `get_workflow`'s result with `kind: "skill"` is not a step. Don't look for it in `list_steps` or call `run_step` on it: call `get_skill` with its `skill` name, plus `@<version>` when it has a `version` (for example `app/point-cloud-character@3`), and do it yourself.

If `get_workflow` returns a `recipe`, follow it; it overrides the style guidance in any skill the workflow uses. A project made from the template's card already has its files (overlays, fonts, images). Any other project needs `install_workflow_assets` first: it copies them in and returns their paths, and skips any file that is already there.

To create or edit a workflow, load the `app/workflow-builder` skill with `get_skill`. It needs Montaj Studio.

Leave out a step's `out` parameter unless the step needs it: the result comes back in the tool's reply. When a later step needs an earlier result as a file (for example `rm_nonspeech` or `crop_spec` taking the trim spec `waveform_trim` returned), save it with `write_file` first, in the project's folder, and pass that path.

Send every parameter with the type `get_step` gives it. Some skills show `crop_spec`'s `keeps` or `virtual_to_original`'s `times` as a JSON array; `get_step` types them as strings, so send a JSON string: `"keeps": "[[8.5, 34.1]]"`, `"times": "[47.32]"`. Use `null` for an open end. `virtual_to_original` takes `times` and `inverse`, not `timestamp` or `verbose`.

Montaj ships one speech model, large-v3-turbo, which handles every language. Leave `model` out. Pass an absolute path for any `out`.

A step that takes a while returns a `jobId` instead of a result, and so does a step Montaj can't start straight away (its status is `queued`). Call `get_step_result` with the newest `jobId` until the result arrives, and tell the user it's working. Never run a step again while its `jobId` is running or queued, even after a timeout: it would run twice. If it stays `queued`, ask the user to look for a Montaj prompt on their screen.

## Looking at frames

You can see images. Run `snapshot` or `sample_frame` to grab a frame from a clip, or `sample_overlay` to render an overlay frame. The picture comes back in the step's reply (up to 4 per result), and `read_file` on any PNG, JPEG or WebP path shows it too. A large image is sent downscaled.

When the user points at something on screen ("here", "where my playhead is", "this frame", "the selected item"), call `get_editor_state` to see where they are looking, then run `sample_frame` at its time to see it.

Check your work visually. After a cut, a crop or an overlay, look at a frame or two before you tell the user it is done: confirm the framing, the text and its position, and that nothing is cut off.

Check your work with `sample_frame`, never with a render: sample each cut and two nearby moments inside a section (identical frames mean it isn't moving). When a full video file is needed, call `render_project` with the project id; the project's status must be `"final"`. It returns at once and the render keeps running in the Montaj app, so tell the user you are rendering, then call `get_render_status` every minute or two (it may take up to 45 seconds to answer) and give them the file path when it is done. Never call `render_project` again while a render is running. If you cannot wait, tell the user and stop: the app notifies them when it is done. Otherwise, when you're done, set the project to `draft` so the user can preview and render it.

## Starting a project the user created in the app

You or the user can create projects. When the user already created one in the app, it exists with status "pending": its clips are imported (unless its video is still downloading, see step 2) and its prompt and workflow are set. Start it; never create another for it. Otherwise make one yourself with `create_project` (`workflow`, `name`, `prompt`, and `clips` as local file paths). It works on any profile on this computer: pass `profile`, and never ask the user to switch. It answers `{projectId, name, workflow, projectType, profile, status}` with status "pending", and you start it with the steps below. A clip of a Clips project is `create_project` with `clip_of` and `clip`. If it answers "Start this one in the Montaj app for now", tell the user that.

A project's `link` (on `list_projects` rows, `get_project` and `create_project`) opens it in Montaj: share it with the user to open the project, or paste it where a tool asks for a Montaj project link.

1. Find it. Use the project id from the user's message, or call `list_projects` with status "pending".
2. Call `get_project`. Read `workflow`, `editingPrompt`, `settings`, `profile` and `profileSnapshot`, and the clips in `tracks[0].items`. `profile` is the profile's id; `list_profiles` has its name. Each clip's `src` is an absolute path you can pass to steps.

   If the project has `sourceDownload` with status `"downloading"`, its video is still downloading from YouTube and `tracks[0].items` is empty. Tell the user, then call `get_step_result` with its `jobId` until it finishes (each call waits up to 45 seconds). If `get_step_result` cannot find the job, call `get_project` again: that resumes the download with a new `jobId`. When it is done, call `get_project` again and start. If the status is `"failed"`, tell the user it could not be downloaded (`error` says why) and stop.

   To bring footage in yourself, call `import_media` with a `url` (a direct media link, YouTube or a signed link) or a local `path`. It returns `{jobId, status}`: call `get_import_status` with the `jobId` until it is `done` (it gives a `path`), then pass that path as `clips` to `create_project`. With `project`, it adds the file to that project's sources instead. If it is `failed` (an expired or forbidden link, say), tell the user and ask for a fresh link.
3. Call `get_workflow` with the project's `workflow`. This is how you "read the workflow" the `montaj` skill mentions.
4. Load the skills the workflow names with `get_skill`, and carry out its steps. Before each step, call `post_progress` with one short line saying what you are about to do, e.g. "Trimming silences from 3 clips", and tell the user in this chat too. The Montaj window shows the line live, so the user can see you are working. Save your progress with `save_project` as you go.
5. When you are done, save `status: "draft"` and tell the user the edit is ready to review in the Montaj app. The user exports it from there.

## Saving

`save_project` merges at the top level. Each field in `changes` replaces that whole field, and every field you leave out stays as it is. So to change one clip, send the whole `tracks` array with that clip changed. To clear a field, send it as null. Leave out `id`.

Always call `get_project` right before you save and build `changes` from what you just read. The user may be editing the same project in the app, and saving from an older copy would undo their work.

## Profiles

In Montaj Studio each style profile has its own trends and Plan. Any profile on this computer can be the target. Call `list_profiles`, and pass that profile's `id` or name as `profile` to `create_project` and to the trends and post tools. Without `profile`, they use the profile active in the Montaj app. Never ask the user to switch profiles. With no profile yet, ask the user to create one in Montaj.

In Pipeline, the Ideas tab holds the user's own notes, which no tool can reach. Plan holds posts (Script, Record, Edit, plus a date that puts a post on the calendar, and a Posted check mark), which the pipeline tools read and write. Trends holds the daily brief, where Develop makes a post.

A `montaj://profile/<id>` resource is named by the profile's id; `list_profiles` has its name.

A profile's Library holds its animations (overlays), images and videos, and stays on this computer. Save with `save_profile_overlay`, `save_profile_image` and `save_profile_video`; list what is there with `list_profile_library`. On Montaj Studio the user shares an item with the team by choosing Add to Brand Kit in the Library; tell them so after you save.

For an overlay, pass settings (durationSeconds, fps, googleFonts, defaults.props) so it previews at its real length and look; pass assets for files it references, like a logo. To reuse it in a video, use the absolute asset paths the save returned as prop values.

To use a library video in a project, call `import_media({path, project})` with its path, then place it with `save_project`: on the main track for an intro or outro, on an upper track for b-roll or a logo sting.

To read or save a profile's style card, the one its Analysis tab shows, call `get_style_card` and `save_style_card`. The `app/style-profile` skill has the card's shape.

## Review notes (Montaj Studio)

When the user sends an export to a client for review, the client leaves notes on the video at a timecode. Open notes are the ones nobody has marked done.

- `get_review_notes` returns every review with open notes, each note with its timecode, the author's name and the text. Pass `id` for one review.
- `create_review_link` makes the review link the app's Create link makes and returns `{ reviewId, url, version }`. Render the project first. On a link with no reviewers, a newer render becomes the next version on the same url; relay any `note` it returns.
- The same notes are also resources named `montaj://review/<id>`, in case this app lets the user attach one to a chat.
- A carousel review's notes are headed by slide, with a point as a percent across and down. Slide N is `project.slides[N-1]`.
- Read only. To mark a note done, tell the user to do it in the Montaj app, and never reply to the client on their behalf.
- Address a note by editing the project at that timecode, then tell the user what you changed. Check the frame before you say it is done.

The user's own notes on a carousel are not review notes: they are in `project.notes`, each with the `slideId` of its slide and, when pinned to a point, `x` and `y` as fractions 0 to 1 across and down. When you fix one, set its `done` to true; never remove it.

## Plans

`get_plan` says the user's Montaj plan and what it locks.

- Don't rebuild a locked feature by hand: no trend research in place of Trends, no recreating a Montaj Hub template's style.
- When the user asks for a locked feature, call its tool. If it says it needs Montaj Hub or Montaj Studio, tell the user and share the link once.
- Never bring up plans or upgrades unprompted.

## Paid generation

`generate_image`, `generate_music`, `generate_sfx`, `generate_voiceover`, `kling_generate` and `seedance_generate` spend the user's own credits with the service they connected. Before running any of them, tell the user what you will make and how many calls it takes, and wait for a yes. One yes covers that batch; ask again before more. Regenerate only what changed.

## Feedback

When the user seems confused or frustrated with Montaj, or something keeps failing, offer once to send feedback to the Montaj team with `submit_feedback`. Send it only if they agree, write it in their words, and tell them what you sent.

## Paths

Every path is absolute. Keep files you write inside the project's folder, the folder that holds its clips, unless a skill says otherwise. Montaj refuses paths outside the user's Montaj workspace.
