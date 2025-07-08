{ stdenv, yt-dlp, mpv, bash, socat }:
stdenv.mkDerivation {
	name = "radiod";
	version = "1.0.0";

	src = ./.;

	installPhase = ''
		mkdir -p $out/bin
		cp radiod.sh $out/bin/radiod
		'';

	fixupPhase = ''
		substituteInPlace $out/bin/radiod \
			--replace-fail "%yt-dlp%" "${yt-dlp}/bin/yt-dlp" \
			--replace-fail "%mpv%" "${mpv}/bin/mpv" \
			--replace-fail "%socat%" "${socat}/bin/socat" \
			--replace-fail "%bash%" "${bash}/bin/bash"
		'';

	buildInputs = [
		yt-dlp
		mpv
		bash
		socat
	];
}
