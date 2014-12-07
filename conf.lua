 designResolution = {width = 3840, height = 2160}
 
 function love.conf(t)
    t.console = false                   -- Attach a console (boolean, Windows only)

    t.window.title = "LArse"          -- The window title (string)
    t.window.width = 640               -- The window width (number)
    t.window.height = 360               -- The window height (number)
    t.window.minwidth = 640            -- Minimum window width if the window is resizable (number)
    t.window.minheight = 360           -- Minimum window height if the window is resizable (number)
    t.window.resizable = true
    t.window.highdpi = true            -- Enable high-dpi mode for the window on a Retina display (boolean). Added in 0.9.1
    t.window.display = 1               -- Index of the monitor to show the window in (number)

    t.modules.audio = true             -- Enable the audio module (boolean)
    t.modules.event = true             -- Enable the event module (boolean)
    t.modules.graphics = true          -- Enable the graphics module (boolean)
    t.modules.image = true             -- Enable the image module (boolean)
    t.modules.joystick = false         -- Enable the joystick module (boolean)
    t.modules.keyboard = true          -- Enable the keyboard module (boolean)
    t.modules.math = true              -- Enable the math module (boolean)
    t.modules.mouse = true             -- Enable the mouse module (boolean)
    t.modules.physics = true           -- Enable the physics module (boolean)
    t.modules.sound = true             -- Enable the sound module (boolean)
    t.modules.system = true            -- Enable the system module (boolean)
    t.modules.timer = true             -- Enable the timer module (boolean)
    t.modules.window = true            -- Enable the window module (boolean)
    t.modules.thread = false           -- Enable the thread module (boolean)
end
