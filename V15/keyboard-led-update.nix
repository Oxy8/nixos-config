{ pkgs, lib, config, ... }:

let
  capslockToggleBinary = pkgs.runCommand "capslock_toggle" {
    buildInputs = [ pkgs.gcc pkgs.linuxHeaders ];
  } ''
    cat > capslock_toggle.c << EOF
    #include <fcntl.h>
    #include <unistd.h>
    #include <string.h>
    #include <linux/uinput.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <time.h>
    #include <errno.h>

    void sleep_ms(int milliseconds) {
        struct timespec ts = {
            .tv_sec = milliseconds / 1000,
            .tv_nsec = (milliseconds % 1000) * 1000000
        };
        nanosleep(&ts, NULL);
    }

    int main(void) {
        struct uinput_setup usetup;
        int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
        if (fd < 0) {
            perror("open /dev/uinput");
            return 1;
        }

        if (ioctl(fd, UI_SET_EVBIT, EV_KEY) < 0 ||
            ioctl(fd, UI_SET_KEYBIT, KEY_CAPSLOCK) < 0) {
            perror("ioctl");
            close(fd);
            return 1;
        }

        memset(&usetup, 0, sizeof(usetup));
        usetup.id.bustype = BUS_USB;
        usetup.id.vendor  = 0x1234;
        usetup.id.product = 0x5678;
        strcpy(usetup.name, "capslock-toggle-device");

        if (ioctl(fd, UI_DEV_SETUP, &usetup) < 0 ||
            ioctl(fd, UI_DEV_CREATE) < 0) {
            perror("UI_DEV_SETUP/CREATE");
            close(fd);
            return 1;
        }

        sleep_ms(100);

        for (int i = 0; i < 2; ++i) {
            struct input_event ev;

            memset(&ev, 0, sizeof(ev));
            gettimeofday(&ev.time, NULL);
            ev.type = EV_KEY;
            ev.code = KEY_CAPSLOCK;
            ev.value = 1;
            write(fd, &ev, sizeof(ev));

            sleep_ms(50);

            memset(&ev, 0, sizeof(ev));
            gettimeofday(&ev.time, NULL);
            ev.type = EV_KEY;
            ev.code = KEY_CAPSLOCK;
            ev.value = 0;
            write(fd, &ev, sizeof(ev));

            memset(&ev, 0, sizeof(ev));
            gettimeofday(&ev.time, NULL);
            ev.type = EV_SYN;
            ev.code = SYN_REPORT;
            ev.value = 0;
            write(fd, &ev, sizeof(ev));

            sleep_ms(500);
        }

        ioctl(fd, UI_DEV_DESTROY);
        close(fd);
        return 0;
    }
    EOF

    gcc -o $out capslock_toggle.c
  '';
in
{
  options = { };
  config = {
    environment.etc."capslock_toggle".source = capslockToggleBinary;

    systemd.services.capslock-toggle-resume = {
      description = "Toggle capslock to fix keyboard LED after resume";
      wantedBy = [ "suspend.target" ];
      after = [ "suspend.target" ];
      serviceConfig = {
        ExecStart = "/etc/capslock_toggle";
        Type = "oneshot";
      };
    };
  };
}
