def name_to_enum(name):
	return name \
		.replace("-", "_") \
		.replace(" ", "_") \
		.replace("'", "") \
		.title()
