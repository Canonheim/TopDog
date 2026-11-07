## SCREEN-SPACE OUTLINE COMPOSITOR, the host. One CompositorEffect per world
## (cel_pass.add_outline_pass) that owns the ink's PUBLIC contract: the
## line_width / line_color snapshot off the `outline_*` shader globals (never
## call global_shader_parameter_get per frame: editor-only API, stalls the
## render thread; read ProjectSettings once), the profile pick, and the R8
## `ink_texture()` ledger a water shader can replay (see
## docs/Outline Shader - How It Works.md) -- and hands every frame to
## outline_adaptive.gd: six compute passes (outline_edges / clean / downsample /
## density / expand / resolve.glsl). Headless-safe: the adaptive effect
## self-disables without a RenderingDevice and this host follows it.
##
## Forward+ only (a compositor needs the RenderingDevice). The profile setting
## `rendering/house_ink/profile` reads "stabilized" (the default: the chain +
## 0.65 motion-vector-reprojected history of ink coverage) or "adaptive" (the
## same chain, no history); anything else warns and takes the default.
extends CompositorEffect

## Chosen once on creation; restart the scene after changing.
const DEFAULT_PROFILE := "stabilized" # "adaptive", "stabilized"
var _adaptive: CompositorEffect = null

var line_color := Color(0.0, 0.0, 0.0, 0.9)
# THE REFERENCE-INCH LAW: line_width is authored in PIXELS AT A 1080-LINE
# BUFFER and scaled to the live render height every frame
# (outline_adaptive.gd: width_px = line_width * size.y / 1080), so the ink
# covers the same fraction of the screen on every monitor and at every
# render scale. Retune outline_width as if on 1080p; every screen follows.
const WIDTH_REF_H := 1080.0
var line_width := 4.0
var _fallback_tex: Texture2DRD = null  # only if the chain never stood up


## THE FINAL INK LEDGER: the resolve pass writes its final ink coverage into a
## self-managed R8 texture the same frame, BEFORE transparents draw; a water
## surface (a transparent that repaints every pixel it covers and would murk
## the line out) can sample it through this Texture2DRD and repaint the line
## on itself. Safe to hand out before the first frame renders (an empty RID
## samples black = no ink).
func ink_texture() -> Texture2DRD:
	if _adaptive != null:
		return _adaptive.ink_texture()
	if _fallback_tex == null:
		_fallback_tex = Texture2DRD.new()
	return _fallback_tex


func _init() -> void:
	# PRE-transparent is THE stage: bars and particles draw over the ink, a
	# water replays it from the final ink ledger. (MSAA is not used; the
	# look is authored for FXAA.)
	effect_callback_type = EFFECT_CALLBACK_TYPE_PRE_TRANSPARENT
	access_resolved_color = true
	access_resolved_depth = true
	needs_normal_roughness = true
	var w = ProjectSettings.get_setting("shader_globals/outline_width", {})
	if w is Dictionary and w.has("value"):
		line_width = float(w["value"])
	var c = ProjectSettings.get_setting("shader_globals/outline_color", {})
	if c is Dictionary and c.has("value") and c["value"] is Color:
		var col: Color = c["value"]
		line_color = Color(col.r, col.g, col.b, maxf(col.a, 0.85))
	var profile := str(ProjectSettings.get_setting(
			"rendering/house_ink/profile", DEFAULT_PROFILE))
	if profile not in ["adaptive", "stabilized"]:
		push_warning("Unknown outline profile '%s'; using %s." % [profile, DEFAULT_PROFILE])
		profile = DEFAULT_PROFILE
	_adaptive = load("res://shaders/cel/outline_adaptive.gd").new()
	_adaptive.line_width = line_width
	_adaptive.line_color = line_color
	_adaptive.temporal_strength = 0.65 if profile == "stabilized" else 0.0
	_adaptive.needs_motion_vectors = profile == "stabilized"
	needs_motion_vectors = _adaptive.needs_motion_vectors
	enabled = _adaptive.enabled  # headless dummy renderer: no-op


func _render_callback(_type: int, render_data: RenderData) -> void:
	if _adaptive == null:
		return
	_adaptive.line_width = line_width
	_adaptive.line_color = line_color
	_adaptive._render_callback(_type, render_data)
