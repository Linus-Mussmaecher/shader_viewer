use winit::{
    event::*,
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    env_logger::init();

    let event_loop = EventLoop::new();

    let window = WindowBuilder::new()
        .with_resizable(false)
        .with_inner_size(winit::dpi::Size::Physical(winit::dpi::PhysicalSize {
            width: 630,
            height: 500,
        }))
        .build(&event_loop)
        .expect("Could not init window.");

    event_loop.run(
        move |event, _event_loop_window_target, control_flow| match event {
            Event::WindowEvent {
                ref event,
                window_id,
            } if window_id == window.id() => match event {
                WindowEvent::CloseRequested => {
                    *control_flow = ControlFlow::Exit;
                }
                WindowEvent::CursorEntered { device_id: _ } => {
                    println!("Entered!");
                }
                WindowEvent::KeyboardInput {
                    input:
                        KeyboardInput {
                            state: ElementState::Pressed,
                            virtual_keycode: Some(VirtualKeyCode::F11),
                            ..
                        },
                    ..
                } => {
                    println!("{:?}", window.fullscreen());
                    if window.fullscreen().is_some() {
                        window.set_fullscreen(None);
                    } else {
                        window.set_fullscreen(Some(winit::window::Fullscreen::Borderless(None)));
                    }
                    println!("{:?}", window.fullscreen());
                }
                _ => {}
            },
            _ => {}
        },
    );
}
