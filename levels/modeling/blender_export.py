"""
Export the "Tiles" collection (root-level only) as a .glb file.

Usage (Blender scripting workspace):
  1. Open Blender's Scripting workspace.
  2. Paste or load this script.
  3. Click "Run Script".

Usage (terminal - errors and print output are visible here):
  "C:/Program Files (x86)/Steam/steamapps/common/Blender/blender.exe" ^
      --background path/to/your_file.blend ^
      --python path/to/blender_export.py

The .glb will be saved next to your .blend file as  <blend_name>_Tiles.glb
(or to FALLBACK_DIR if the file hasn't been saved yet).
"""

import bpy
import os

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

COLLECTION_NAME = "Tiles"          # Name of the root-level collection to export
FALLBACK_DIR    = "/tmp"           # Used when the .blend file has no path yet

# glTF export settings – tweak to match your pipeline
EXPORT_OPTIONS = dict(
    filepath             = "",      # set at runtime
    use_selection        = True,    # export only the selected objects
    use_active_collection= False,
    export_format        = "GLB",
    export_apply         = False,   # apply modifiers?  change to True if needed
    export_animations    = True,
    export_skins         = True,
    export_yup           = True,    # Y-up (glTF standard); set False for Z-up
    export_texcoords     = True,
    export_normals       = True,
    export_vertex_color  = "MATERIAL",
    export_materials     = "EXPORT",
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def get_root_collection(name: str):
    """Return the collection if it is a direct child of the Scene Collection."""
    scene_col = bpy.context.scene.collection
    for col in scene_col.children:
        if col.name == name:
            return col
    return None


def all_objects_in_collection(col):
    """Recursively collect every object inside *col* and its sub-collections."""
    objects = set(col.objects)
    for child in col.children:
        objects |= all_objects_in_collection(child)
    return objects


def build_export_path() -> str:
    blend_path = bpy.data.filepath
    if blend_path:
        directory = os.path.dirname(blend_path)
        blend_stem = os.path.splitext(os.path.basename(blend_path))[0]
        filename   = f"{blend_stem}_{COLLECTION_NAME}.glb"
    else:
        directory = FALLBACK_DIR
        filename  = f"{COLLECTION_NAME}.glb"
    return os.path.join(directory, filename)


# ---------------------------------------------------------------------------
# Main export routine
# ---------------------------------------------------------------------------

def export_tiles():
    # 1. Find the collection
    tiles_col = get_root_collection(COLLECTION_NAME)
    if tiles_col is None:
        raise RuntimeError(
            f'Collection "{COLLECTION_NAME}" was not found as a direct child '
            f'of the Scene Collection. Check the name and try again.'
        )

    # 2. Gather objects
    export_objects = all_objects_in_collection(tiles_col)
    if not export_objects:
        raise RuntimeError(f'Collection "{COLLECTION_NAME}" contains no objects.')

    print(f'[Export] Found {len(export_objects)} object(s) in "{COLLECTION_NAME}":')
    for obj in sorted(export_objects, key=lambda o: o.name):
        print(f'         • {obj.name}  ({obj.type})')

    # 3. Deselect everything, then select only the Tiles objects
    bpy.ops.object.select_all(action='DESELECT')
    for obj in export_objects:
        obj.select_set(True)

    # 4. Build output path
    out_path = build_export_path()
    EXPORT_OPTIONS["filepath"] = out_path

    # 5. Export
    bpy.ops.export_scene.gltf(**EXPORT_OPTIONS)

    # 6. Restore selection state (deselect our objects)
    bpy.ops.object.select_all(action='DESELECT')

    print(f'\n[Export] ✓  Saved → {out_path}')
    return out_path


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    try:
        result = export_tiles()
    except Exception as exc:
        import traceback
        print("\n[Export] ✗  Export failed:")
        traceback.print_exc()