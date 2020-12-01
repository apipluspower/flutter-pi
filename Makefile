REAL_CFLAGS = -I./include $(shell pkg-config --cflags gbm libdrm glesv2 egl libsystemd libinput libudev) \
        -DBUILD_TEXT_INPUT_PLUGIN \
        -DBUILD_TEST_PLUGIN \
        -DBUILD_OMXPLAYER_VIDEO_PLAYER_PLUGIN \
        -O0 -ggdb \
        $(CFLAGS)

REAL_LDFLAGS = \
        $(shell pkg-config --libs gbm libdrm glesv2 egl libsystemd libinput libudev) \
        -lrt \
        -lpthread \
        -ldl \
        -lm \
        -rdynamic \
        $(LDFLAGS)

SOURCES = src/flutter-pi.c \
        src/platformchannel.c \
        src/pluginregistry.c \
        src/console_keyboard.c \
        src/texture_registry.c \
        src/compositor.c \
        src/modesetting.c \
        src/collection.c \
        src/cursor.c \
        src/plugins/services.c \
        src/plugins/testplugin.c \
        src/plugins/text_input.c \
        src/plugins/raw_keyboard.c \
        src/plugins/gpiod.c \
        src/plugins/spidev.c \
        src/plugins/omxplayer_video_player.c

OBJECTS = $(patsubst src/%.c,out/obj/%.o,$(SOURCES))
.PHONY: out/flutter-pi
all: out/flutter-pi

out/obj/%.o: src/%.c
        @mkdir -p $(@D)
        $(CC) -c $(REAL_CFLAGS) $< -o $@


out/flutter-pi: $(OBJECTS)
	#installing flutter-pi engine binaries
	sudo apt-get update     
	sudo cp ../engine-binaries/libflutter_engine.so.* ../engine-binaries/icudtl.dat /usr/lib
	sudo cp ../engine-binaries/flutter_embedder.h /usr/include
	@echo 'Completed'
	# installing dependencies
	sudo apt install -y libgl1-mesa-dev libgles2-mesa-dev libegl-mesa0 libdrm-dev libgbm-dev
	sudo apt-get install -y gpiod libgpiod-dev libsystemd-dev libinput-dev libudev-dev
	# fixing GPU Permission
	sudo usermod -a -G render pi
	# Installing Flutter-Pi
	@echo 'Installing Flutter-Pi.'
	sudo apt install -y make
	sudo cp -r ../flutter-pi ~
	sudo chmod 775 ~/flutter-pi
	cd ~/flutter-pi
	echo 'Compiling...'
	@mkdir -p $(@D)
	$(CC) $(REAL_CFLAGS) $(REAL_LDFLAGS) $(OBJECTS) -o out/flutter-pi
	@echo
	@echo 'flutter-pi installation completed :) '
	@echo 'Restart terminal and try command "flutter-pi"...'
	@echo
	
	for i in *; do echo "i=$$i"; done
	sudo echo 'export PATH="$$PATH:/home/pi/flutter-pi/out/"' >> ~/.bashrc
	source ~/.bashrc

clean:
	rm -rf out

