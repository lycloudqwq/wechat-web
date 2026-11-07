FROM lsiobase/selkies:debiantrixie

ENV LC_ALL=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    PIXELFLUX_WAYLAND=true \
    RESTART_APP=true \
    DISABLE_SUDO=true \
    DISABLE_TERMINALS=true \
    NO_DECOR=true \
    NO_FULL=true \
    NO_GAMEPAD=true \
    TITLE="WeChat" \
    SELKIES_UI_LAYOUT=wish \
    SELKIES_UI_SHOW_LOGO=false \
    SELKIES_UI_SIDEBAR_SHOW_APPS=false \
    SELKIES_UI_SIDEBAR_SHOW_SHARING=false \
    SELKIES_UI_SIDEBAR_SHOW_FULLSCREEN=false \
    SELKIES_UI_SIDEBAR_SHOW_GAMING_MODE=false \
    SELKIES_UI_SIDEBAR_SHOW_TRACKPAD=false \
    SELKIES_UI_SIDEBAR_SHOW_KEYBOARD_BUTTON=false \
    SELKIES_ENABLE_SHARING=false \
    SELKIES_COMMAND_ENABLED=false \
    SELKIES_MANUAL_WIDTH=1920 \
    SELKIES_MANUAL_HEIGHT=1080 \
    SELKIES_SCALING_DPI=144 \
    SELKIES_FRAMERATE=120 \
    SELKIES_VIDEO_FULLCOLOR=true

RUN set -eu; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
        amd64) wechat_arch="x86_64" ;; \
        arm64) wechat_arch="arm64" ;; \
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl --fail --fail-early --location \
        --retry 5 --retry-delay 10 --retry-all-errors \
        --connect-timeout 30 \
        --output /tmp/wechat.deb \
        "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_${wechat_arch}.deb" \
        --output /usr/share/selkies/www/icon.png \
        "https://res.wx.qq.com/a/wx_fed/assets/res/NTI4MWU5.ico"; \
    test "$(dpkg-deb -f /tmp/wechat.deb Architecture)" = "$arch"; \
    test -s /usr/share/selkies/www/icon.png; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        /tmp/wechat.deb; \
    rm -f /tmp/wechat.deb; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    printf '%s\n' \
        '#!/bin/sh' \
        'export QT_QPA_PLATFORM=wayland' \
        'wechat' \
        'while pgrep -x wechat >/dev/null; do sleep 2; done' \
        > /defaults/autostart_wayland
