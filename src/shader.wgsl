// Vertex shader

struct ShaderInfo {
    time: f32,
    w: u32,
    h: u32,
}

@group(0) @binding(0)
var<uniform> shader_info: ShaderInfo;


struct VertexInput {
    @location(0) position: vec3<f32>,
}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) vert_pos: vec2<f32>,
    @location(1) time: f32,
};


@vertex
fn vs_main(
    vertex: VertexInput,
) -> VertexOutput {
    var out: VertexOutput;
    out.clip_position = vec4<f32>(vertex.position.xyz, 1.0);
    out.vert_pos = out.clip_position.xy;
    out.vert_pos.x *= f32(shader_info.w) / f32(shader_info.h);
    out.time = shader_info.time;
    return out;
}


@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let time = in.time;
    let uv = in.vert_pos.xy;

    var color = palette(sdPi(uv) + time);

    let angle = 6.28 * cos(time);

    let uv_turn = vec2(uv.x * cos(angle) - uv.y * sin(angle), uv.y * cos(angle) + uv.x * sin(angle));

    var r = sin(8. * sdPi(uv) - time);

    r = min(abs(r), sdPi(uv_turn));
    r = 0.02 / r;

    var uv2 = uv;

    color = r * color;

    for (var i = 0.0; i < 4.0; i += 1.0) {
        uv2 = abs(fract((0.7 + 0.07 * sin(0.628 * time) + 0.45 * sin(0.0314 * time)) * uv2) - 0.5);

        // r += 0.02 / sin(31.4 * (
        //     abs(length(uv2))
        // ) + time);

        let sub_r = 0.01 / sin(31.4 * (abs(length(uv2))) + time);

        color += sub_r * palette(length(uv2) + time + i / 0.314);
    }

    if sdPi(uv_turn) <= 0.0 {
        color = 0.0 * color;
    }

    color = pow(color, vec3(1.6));

    return vec4(color, 1.0);
}

fn palette(t: f32) -> vec3<f32> {
    // let a = vec3(0.975, 0.827, 1.836);
    // let b = vec3(0.973, 0.903, 0.811);
    // let c = vec3(1.062, 0.055, 0.881);
    // let d = vec3(0.389, 5.670, 4.065);    

    let a = vec3(0.030, 0.540, 0.600,);
    let b = vec3(0.000, 0.350, 0.300,);
    let c = vec3(1.800, 1.800, 0.900,);
    let d = vec3(0.000, 0.000, 0.000,);


    return a + b * cos(6.28318 * (c * t + d));
}

fn sdUnevenCapsule(p: vec2<f32>, r1: f32, r2: f32, h: f32) -> f32 {
    var p: vec2<f32> = p;
    p.x = abs(p.x);
    let b = (r1 - r2) / h;
    let a = sqrt(1.0 - b * b);
    let k = dot(p, vec2<f32>(-b, a));
    if k < 0.0 {
        return length(p) - r1;
    }
    if k > a * h {
        return length(p - vec2(0.0, h)) - r2;
    }
    return dot(p, vec2(a, b)) - r1;
}

fn sdRoundedBox(p: vec2<f32>, b: vec2<f32>, r: vec4<f32>) -> f32 {
    var r: vec4<f32> = r;
    r.x = select(r.z, r.x, p.x > 0.0);
    r.y = select(r.w, r.y, p.x > 0.0);
    r.x = select(r.y, r.x, p.y > 0.0);
    let q = abs(p) - b + r.x;
    return min(max(q.x, q.y), 0.0) + length(vec2(max(q.x, 0.0), max(q.y, 0.0))) - r.x;
}

fn sdPi(p: vec2<f32>) -> f32 {
    let sd1 = sdUnevenCapsule(p + vec2(0.1, 0.2), 0.035, 0.02, 0.4);
    let sd2 = sdUnevenCapsule(p + vec2(-0.1, 0.2), 0.035, 0.02, 0.4);
    let sd3 = sdRoundedBox(p + vec2(0., -0.2), vec2(0.2, 0.05), vec4(0.01, 0.025, 0.025, 0.025));

    return min(
        sd1,
        min(sd2, sd3)
    );
}
