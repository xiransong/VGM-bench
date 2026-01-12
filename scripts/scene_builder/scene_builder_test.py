"""
VGM-bench: Scene Builder v0
- Simple room + obstacle boxes
- No camera, no task, no motion
"""

import bpy
import os
from mathutils import Vector

# ============================================================
# Config
# ============================================================

SCENE_ID = "scene_v0_0001"

OUTPUT_DIR = os.path.expanduser("~/scratch/data")
BLEND_PATH = os.path.join(OUTPUT_DIR, f"{SCENE_ID}.blend")
PREVIEW_PATH = os.path.join(OUTPUT_DIR, f"{SCENE_ID}_preview.png")

ROOM_SIZE = Vector((8.0, 8.0, 3.0))   # meters (X, Y, Z)
WALL_THICKNESS = 0.1
FLOOR_THICKNESS = 0.1

OBSTACLES = [
    Vector(( 1.5,  0.0, 0.5)),
    Vector((-1.5, -1.0, 0.5)),
    Vector(( 0.0,  2.0, 0.5)),
]

OBSTACLE_SIZE = Vector((0.8, 0.8, 1.0))

# ============================================================
# Utilities
# ============================================================

def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    bpy.ops.outliner.orphans_purge(do_recursive=True)


def add_box(name, size, location):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size / 2.0
    return obj


# ============================================================
# Scene construction
# ============================================================

def build_room():
    # Floor
    add_box(
        "floor",
        Vector((ROOM_SIZE.x, ROOM_SIZE.y, FLOOR_THICKNESS)),
        Vector((0, 0, -FLOOR_THICKNESS / 2)),
    )

    # Walls
    half_x = ROOM_SIZE.x / 2
    half_y = ROOM_SIZE.y / 2
    wall_h = ROOM_SIZE.z

    # +X / -X walls
    add_box("wall_pos_x",
        Vector((WALL_THICKNESS, ROOM_SIZE.y, wall_h)),
        Vector(( half_x, 0, wall_h / 2))
    )
    add_box("wall_neg_x",
        Vector((WALL_THICKNESS, ROOM_SIZE.y, wall_h)),
        Vector((-half_x, 0, wall_h / 2))
    )

    # +Y / -Y walls
    add_box("wall_pos_y",
        Vector((ROOM_SIZE.x, WALL_THICKNESS, wall_h)),
        Vector((0,  half_y, wall_h / 2))
    )
    add_box("wall_neg_y",
        Vector((ROOM_SIZE.x, WALL_THICKNESS, wall_h)),
        Vector((0, -half_y, wall_h / 2))
    )


def build_obstacles():
    for i, pos in enumerate(OBSTACLES):
        add_box(
            f"obstacle_{i}",
            OBSTACLE_SIZE,
            pos
        )


# ============================================================
# Preview rendering (simple, fixed camera)
# ============================================================

def render_preview():
    # Add a simple camera
    bpy.ops.object.camera_add(
        location=(10, -10, 6),
        rotation=(1.1, 0, 0.9)
    )
    cam = bpy.context.active_object
    bpy.context.scene.camera = cam

    # Light
    bpy.ops.object.light_add(
        type="SUN",
        location=(0, 0, 10)
    )

    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.render.filepath = PREVIEW_PATH
    scene.render.resolution_x = 512
    scene.render.resolution_y = 512
    scene.cycles.samples = 16

    bpy.ops.render.render(write_still=True)


# ============================================================
# Main
# ============================================================

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    clear_scene()
    build_room()
    build_obstacles()
    render_preview()

    bpy.ops.wm.save_as_mainfile(filepath=BLEND_PATH)

    print("===================================================")
    print("✅ Scene built successfully")
    print(f"📦 Scene file: {BLEND_PATH}")
    print(f"🖼  Preview:   {PREVIEW_PATH}")
    print("===================================================")


if __name__ == "__main__":
    main()
