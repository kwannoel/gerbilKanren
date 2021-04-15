##
# Gerbil Scheme MicroKanren
#
# @file
# @version 0.1

hello-world:
	GERBIL_PATH=./build gxc hello-world.ss
	GERBIL_PATH=./build gxi

kanren:
	GERBIL_PATH=./build gxc kanren.ss
	GERBIL_PATH=./build gxi

kanren-test:
	GERBIL_PATH=./build gxc kanren.ss
	GERBIL_PATH=./build gxi kanren-test.ss

# end
