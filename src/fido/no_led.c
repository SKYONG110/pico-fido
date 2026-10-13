/*
 * Pico FIDO - No-LED build support.
 *
 * This file is only compiled when the DISABLE_LED CMake option is enabled
 * (default: ON). It is linked with -Wl,--wrap,led_init, so every call to
 * led_init() (made by the Pico Keys SDK's main.c during boot) is redirected
 * here instead of the SDK's real led_init().
 *
 * Instead of probing and initializing a real LED driver (onboard LED, CYW43,
 * WS2812, NeoPixel, ...), we install a no-op driver. From this point on,
 * every LED API (led_blink_n_times(), led_blinking_task(), led_off_all(),
 * fido_led_3_blinks(), ...) still runs, but the driver's set_color() does
 * nothing, so no LED hardware is ever initialized or driven: the firmware
 * is completely LED-free from boot to shutdown.
 *
 * The SDK's real led_init() remains available as __real_led_init() should
 * it ever be needed (e.g. for debugging).
 */

#include "led/led.h"

static void noled_init(void) {
}

static void noled_set_color(uint8_t color, uint32_t led_brightness, float progress) {
    (void) color;
    (void) led_brightness;
    (void) progress;
}

static led_driver_t noled_driver = {
    .init = noled_init,
    .set_color = noled_set_color,
};

void __wrap_led_init(void);

void __wrap_led_init(void) {
    /* Never touch real LED hardware: install the no-op driver. */
    led_driver = &noled_driver;
    led_set_mode(MODE_ALWAYS_OFF);
}
