// Vertex shader

struct ShaderInfo{
    time: u32,
    w: u32,
    h: u32,
}

@group(0) @binding(0)
var<uniform> shader_info: ShaderInfo;


struct VertexInput{
    @location(0) position: vec3<f32>,
}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) vert_pos: vec3<f32>,
    @location(1) time: u32,
};


@vertex
fn vs_main(
    vertex: VertexInput,
) -> VertexOutput{
    var out: VertexOutput;
    out.clip_position = vec4<f32>(vertex.position.xyz,1.0);
    out.vert_pos = out.clip_position.xyz;
    out.time = shader_info.time;
    return out;
}


@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    var val: f32 = 0.1;
    if sdPi(in.vert_pos.xy) < 0.01 {
        val = sin(f32(in.time) / 314.);
    }

    return vec4<f32>(0.4, 0.4, val, 1.0);
}

fn sdUnevenCapsule(p: vec2<f32>, r1: f32, r2: f32, h: f32 ) -> f32
{
    var p: vec2<f32> = p;
    p.x = abs(p.x);
    let b = (r1-r2)/h;
    let a = sqrt(1.0-b*b);
    let k = dot(p,vec2<f32>(-b,a));
    if( k < 0.0 ) {
        return length(p) - r1;
    }
    if( k > a*h ) {
        return length(p-vec2(0.0,h)) - r2;
    }
    return dot(p, vec2(a,b) ) - r1;
}

fn sdRoundedBox(p: vec2<f32>, b: vec2<f32>, r: vec4<f32> ) -> f32
{
    var r: vec4<f32> = r;
    r.x =  select(r.z, r.x, p.x>0.0);
    r.y =  select(r.w, r.y, p.x>0.0);
    r.x  = select(r.y, r.x, p.y>0.0);
    let q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(vec2(max(q.x,0.0), max(q.y, 0.0))) - r.x;
}

fn sdPi(p: vec2<f32>) -> f32
{
    let sd1 = sdUnevenCapsule(p + vec2(0.1, 0.2), 0.035, 0.02, 0.4);
    let sd2 = sdUnevenCapsule(p + vec2(-0.1, 0.2), 0.035, 0.02, 0.4);
    let sd3 = sdRoundedBox(p + vec2(0., -0.2), vec2(0.2, 0.05), vec4(0.01, 0.025, 0.025, 0.025));
    
    return min(
        sd1, min(sd2, sd3)
    );
}
