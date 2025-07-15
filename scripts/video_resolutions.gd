extends Node

const R16_9 = {
	"640x360": Vector2i(640, 360),		# nHD
	"960x540": Vector2i(960, 540),		# qHD
	"1280x720": Vector2i(1280, 720),		# HD / 720p
	"1366x768": Vector2i(1366, 768),     # WXGA++  (Common laptop resolution)
	"1600x900": Vector2i(1600, 900),		# HD+ / 900p
	"1920x1080": Vector2i(1920, 1080),	# FHD / 1080p
	"2560x1440": Vector2i(2560, 1440),	# QHD / WQHD / 1440p
	"3200x1800": Vector2i(3200, 1800),    # QHD+
	"3840x2160": Vector2i(3840, 2160),	# UHD / 4K / 2160p
	"5120x2880": Vector2i(5120, 2880),    # 5K
	"7680x4320": Vector2i(7680, 4320),	# FUHD / 8K / 4320p
	"15360x8640": Vector2i(15360, 8640),  # 16K
}

const R4_3 = {
	"640x480": Vector2i(640, 480),		# VGA
	"800x600": Vector2i(800, 600),		# SVGA
	"1024x768": Vector2i(1024, 768),		# XGA
	"1152x864": Vector2i(1152, 864),		# XGA+
	"1280x960": Vector2i(1280, 960),      # SXGA-
	"1400x1050": Vector2i(1400, 1050),	# SXGA+
	"1600x1200": Vector2i(1600, 1200),	# UXGA
	"1920x1440": Vector2i(1920, 1440),    # QXGA-
	"2048x1536": Vector2i(2048, 1536),	# QXGA
	"3200x2400": Vector2i(3200, 2400),	# QUXGA
	"6400x4800": Vector2i(6400,4800)
}

const R21_9 = {
	"1280x540": Vector2i(1280, 540),      # Lower resolution
	"1600x670": Vector2i(1600, 670),      # Lower resolution
	"1920x800": Vector2i(1920, 800),      # Lower resolution
	"2560x1080": Vector2i(2560, 1080),	# WFHD
	"3440x1440": Vector2i(3440, 1440),	# WQHD
	"3840x1600": Vector2i(3840, 1600),    # UWQHD
	"5120x2160": Vector2i(5120, 2160),	# WUHD
	"6880x2880": Vector2i(6880, 2880),    # 6K
	"7680x3200": Vector2i(7680, 3200),    # 7.5K
	"10240x4320": Vector2i(10240, 4320),  # 10K  (More accurately 21.33:9)
}

# Technically, 16:10 is 8:5,  but 16:10 is the common term.
const R16_10 = {
	"640x400": Vector2i(640, 400),        # WGA
	"960x600": Vector2i(960, 600),        # WSVGA
	"1152x720": Vector2i(1152, 720),      # WXGA-
	"1280x800": Vector2i(1280, 800),		# WXGA
	"1440x900": Vector2i(1440, 900),		# WXGA+
	"1680x1050": Vector2i(1680, 1050),	# WSXGA+
	"1920x1200": Vector2i(1920, 1200),	# WUXGA
	"2560x1600": Vector2i(2560, 1600),	# WQXGA
	"2880x1800": Vector2i(2880, 1800),    # WQXGA+
	"3840x2400": Vector2i(3840, 2400),    # WQUXGA
	"5120x3200": Vector2i(5120, 3200),    # WHUXGA
	"7680x4800": Vector2i(7680, 4800),    # WHUXGA+
}
