FROM debian:jessie-slim

RUN apt-get update
RUN apt-get install -y wget zip

WORKDIR /godot

RUN wget -O godot.zip https://downloads.tuxfamily.org/godotengine/3.1.1/Godot_v3.1.1-stable_linux_headless.64.zip \
	&& unzip godot.zip && mv Godot_v3.1.1-stable_linux_headless.64 /usr/bin/godot && rm godot.zip

RUN wget -O export-templates.tpz https://downloads.tuxfamily.org/godotengine/3.1.1/Godot_v3.1.1-stable_export_templates.tpz && \
	mkdir -p ~/.local/share/godot/templates && \
        unzip export-templates.tpz -d ~/.local/share/godot/templates && \
        mv ~/.local/share/godot/templates/templates ~/.local/share/godot/templates/3.1.1.stable && \
	rm export-templates.tpz

RUN mkdir /game-builds

ADD ./export_all.sh .

ENTRYPOINT ["sh", "./export_all.sh"]
