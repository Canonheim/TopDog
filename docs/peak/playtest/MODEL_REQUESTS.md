# Peak playtest: models to ask the makers for

From the 11-12 playtest's notes 12 to 57. Each entry is something a note asks for that
needs a model no kit piece gives. Nothing here was faked or downloaded. Where a note
could be tried without the model, that part was done and the entry says what stands in
its place today. Requests go through the Top Dog session.

Every model: applied transforms, the one atlas material, no emissive, metres, y up, x to
the right as you look at the climb, z toward the camera. "Zero" is where the model's
own origin must be.

---

## Note 47: the great mask's carved features, as outlines (Building Maker)

- **What:** not a new model. The outlines of `mask_first_dog`'s own carved features, so
  their collisions can be cut from the carving: each upper tooth, the two upper fangs,
  the upper lip, the two nostrils, the two eye sockets' lower rims, the brow ridge.
  And for `mask_jaw`: its top surface and its two lower fangs.
- **Form:** for each feature a closed 2D outline (x, y) in the model's own metres, in
  the mask's front plane, as a list of points; a JSON file beside the model is ideal
  (`kit/models/mask_first_dog.features.json`).
- **Why:** Parker 11-12: "this whole thing needs to kinda be fixed as far as what you
  can connect with. But it looks great other than interacting with it". The holds a
  climber takes today are the area author's own small blocks (a lip, three teeth, two
  nostrils, two cheekbones, two eye rims, a brow), laid out before the mask was
  modelled. They do not line up with the carving.
- **The mask in the game:** drawn at 2.1 times its modelled size (9 x 10 x 2 m becomes
  18.9 x 21 x 4.2 m), zero at the middle of its base, at (-358.15, 380.2), z -2.9.
- **In place today:** the author's blocks, in the play plane, in front of the mask.
  The climber is no longer behind the mask (done). The route was not re-laid.

## Note 23: a warning plate for the first hot joint (Prop Maker)

- **What:** a small wall sign in the mine-sign style (as `sign_pug_skull`): a hand and
  a flame. "A sign in the world, not a pop-up."
- **Size:** 1.0 wide x 2.2 tall x 0.1 deep on its post, the same as `sign_pug_skull`.
  Zero at the middle of the post's foot.
- **Where:** beside the first hot joint of challenge 2.9, at (-348.2, 118.2), z -1.0;
  and a second by the first hot hold of 6.2, at (-277.6, 486.0).
- **Name:** `sign_hot_hand`.
- **In place today:** nothing. The hot holds themselves now show what they do.
