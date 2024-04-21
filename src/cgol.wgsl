struct Params {
  t: f32
}
@group(0) @binding(0) var cell_read : texture_2d<f32>;
@group(0) @binding(1) var cell_write : texture_storage_2d<rgba8unorm, write>;
@group(0) @binding(2) var screen : texture_storage_2d<rgba8unorm, write>;
@group(0) @binding(3) var<uniform> params : Params;

fn get_index(x: u32, y: u32) -> vec2<u32> {
    return vec2(x & 255, y & 255);
}
fn get_cell(x: u32, y: u32) -> u32 {
    return u32(textureLoad(cell_read, get_index(x, y), 0).x);
}
fn count_neighbors(x: u32, y: u32) -> u32 {
    return get_cell(x - 1, y - 1) + get_cell(x, y - 1) + get_cell(x + 1, y - 1) + get_cell(x - 1, y) + get_cell(x + 1, y) + get_cell(x - 1, y + 1) + get_cell(x, y + 1) + get_cell(x + 1, y + 1);
}
fn store_to_screen(location: vec2<u32>, v: u32) {
    let t = textureDimensions(screen);
    if t.x > location.x && t.y > location.y {
        textureStore(screen, location, vec4<f32>(v));
    }
}
@compute @workgroup_size(1)
fn start(@builtin(global_invocation_id) id: vec3<u32>) {
    let n = count_neighbors(id.x, id.y);
    let c = get_cell(id.x, id.y);
    let a = u32(n == 3u);
    let b = u32(n == 2u || n == 3u);
    let v = select(a, b, (c == 1u));
    textureStore(cell_write, id.xy, vec4<f32>(v));
    store_to_screen(id.xy * 2, v);
    store_to_screen(id.xy * 2 + vec2(1, 0), v);
    store_to_screen(id.xy * 2 + vec2(0, 1), v);
    store_to_screen(id.xy * 2 + vec2(1, 1), v);
}
