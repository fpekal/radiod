{ stdenv, yt-dlp, mpv }:
stdenv.mkDerivation {
	name = "radiod";
	version = "0.0.1";

	src = ./.;

	buildInputs = [
		yt-dlp
		mpv
		bash
	];
}
