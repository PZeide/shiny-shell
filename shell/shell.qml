//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_MEDIA_BACKEND=ffmpeg
//@ pragma Env QT_FFMPEG_DECODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_FFMPEG_ENCODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma UseQApplication

import Quickshell
import Shiny.Location

ShellRoot {
    id: root

    GeoClueAgent {
        onRequestReceived: request => {
            console.info(request.desktopId);
            request.authorize(true);
        }
    }
}
