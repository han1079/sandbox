# --------------- Makefile for Arduino Project ---------------#
# This Makefile is designed to compile an Arduino project using the avr-g++ compiler.
# It includes all the necessary flags, libraries, and paths to compile the project successfully.
# It is a generic Makefile that can be used for any Arduino project with minimal modifications.
# It assumes that the Arduino IDE is installed and the necessary libraries are available in the default locations.

# The tricky part is that you need to have the Arduino IDE installed, but be able to find the avr-g++ compiler
# As well as the necessary libraries and paths to compile the project.
# The paths are set to the default locations where the Arduino IDE installs the avr-g++ compiler and libraries.
# For this particular Makefile, it is set to the Arduino IDE version 1.8.6 and the avr-gcc version 7.3.0-atmel3.6.1-arduino7.

# ------------------THE BUILD DIRECTORY------------------#
# If you don't have a build directory, you end up with a bunch of garbage files in your project directory.
# This is the directory where all the compiled files will be placed.
# This way, when you run clean, you can nicely return to a clean state.
BUILD_DIR = build

# ------------------COMPILER LOCATION------------------#
# This is the location of the avr-g++ compiler that will be used to compile the Arduino project.
# You will need to manually check the path to the avr-g++ compiler on your system.
# The path is largely dependent on HOW you installed the Arduino IDE. VERY annoying.
# Sometimes it's in /usr/bin/avr-g++, sometimes it's in /usr/local/bin/avr-g++, sometimes it's in your home directory.
# This is the path that I found because I used an AppImage to install the Arduino IDE.
THIS_RUNS_THE_COMPILER = ${HOME}/.arduino15/packages/arduino/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7/bin/avr-g++

# ------------------ARDUINO LIBRARY LOCATIONS------------------#
# These are the locations of the Arduino libraries that will be used to compile the project.
# This should be located in a similar place as the avr-g++ compiler.
# This is where the Arduino IDE abstractions are located. Things like digitalWrite, pinMode, etc.
# Specifically, you need to provide the path to the DIRECTORIES.

# Also depending on the HARDWARE you are using, the PIN ALIASES may be different.
# This is located in a DIFFERENT directory than MOST of the .h files. 
# Look for a "variants" directory. Most of the time, standard is the right one.
# However, Mega, Leonardo, Micro, etc, will have different variants.
EXTERNAL_LIBRARIES = ${HOME}/.arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino
PIN_ALIASES = ${HOME}/.arduino15/packages/arduino/hardware/avr/1.8.6/variants/standard

# ------------------CRITICAL VARIABLES------------------#
# AVR-GCC Compilers will be VERY angry if you don't specify the microcontroller and clock frequency.
# This is the microcontroller that you are using. It is set to ATmega328P, which is the default for Arduino Uno and Nano.
# If you are using a different microcontroller, you will need to change this accordingly.
mmcu = atmega328p
F_CPU = 16000000L

# ------------------INCLUDE FLAGS------------------#
# These are the include flags that will be passed to the compiler.
# The -I flag tells the compiler where to look for header files.
# By packing it all into a single variable, you can use the same flags for all the compilation commands
# This works because we are using a strict superset of all the flags that the compiler needs for each command.
DASH_I_STUFF = -I${EXTERNAL_LIBRARIES} -I${PIN_ALIASES} -mmcu=${mmcu} -DF_CPU=${F_CPU} -std=gnu++11 -fpermissive -Os

# ------------------ARDUINO C AND CPP FILES------------------#
# These are the locations of the Arduino C and C++ files that will be compiled.
# The paths are again, a manual search, although Arduino's install should include them in the SAME directory as the .h files.

# The wildcard function here is basically a type of regex search called terminal globbing.
# It will find all the .c and .cpp files in the specified directory.
# The := command basically appends the results of the wildcard search to the variable.
# The result is a list of all the .c and .cpp files in the specified directory.
# Remember. These are just PATHS to FILES. They're used so the compiler knows where to find the files.
DIRECTORY_WHERE_ALL_THE_ARDUINO_C_AND_CPP_FILES_ARE := ${HOME}/.arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino
ALL_THE_ARDUINO_C_FILE_LOCATIONS := $(wildcard ${DIRECTORY_WHERE_ALL_THE_ARDUINO_C_AND_CPP_FILES_ARE}/*.c)
ALL_THE_ARDUINO_CPP_FILE_LOCATIONS := $(wildcard ${DIRECTORY_WHERE_ALL_THE_ARDUINO_C_AND_CPP_FILES_ARE}/*.cpp)
ALL_THE_ARDUINO_S_FILE_LOCATIONS := $(wildcard ${DIRECTORY_WHERE_ALL_THE_ARDUINO_C_AND_CPP_FILES_ARE}/*.S)

# ------------------ARDUINO C AND CPP FILES NAMES------------------#
# These are JUST the names of the files. 
# Having the full path is useful for the compiler, but getting STRICTLY the files names is important for the object files.
ALL_THE_ARDUINO_C_FILE_NAMES := $(notdir ${ALL_THE_ARDUINO_C_FILE_LOCATIONS})
ALL_THE_ARDUINO_CPP_FILE_NAMES := $(notdir ${ALL_THE_ARDUINO_CPP_FILE_LOCATIONS})
ALL_THE_ARDUINO_S_FILE_NAMES := $(notdir ${ALL_THE_ARDUINO_S_FILE_LOCATIONS})

# ------------------ARDUINO C AND CPP OBJECT FILE NAMES------------------#
# These are the names of the object files that will be generated from the Arduino C and C++ files.
# Since EACH .c and .cpp file that is compiled will generate a .o file - it's only SANE to have them be the same name.
# These variables basically take that giant list of .c and .cpp file locations and just swaps the .c and .cpp for .o.
# Since we conveniently extracted the file names in the previous step, we can just use those names.
# This is done using the variable substitution feature of Makefiles.
# The .c=.o and .cpp=.o means that it will replace the .c and .cpp extensions with .o.
# This is a common pattern in Makefiles to generate object files from source files.
ALL_THE_ARDUINO_C_O_FILES_NAMES := ${ALL_THE_ARDUINO_C_FILE_NAMES:.c=.o}
ALL_THE_ARDUINO_CPP_O_FILES_NAMES := ${ALL_THE_ARDUINO_CPP_FILE_NAMES:.cpp=.o}
ALL_THE_ARDUINO_S_O_FILE_NAMES := $(ALL_THE_ARDUINO_S_FILE_NAMES:.s=.o)

# Since these files are in the build directory, we need to prepend the build directory to the names.
# patsubst looks for a thing following the pattern in %, and replaces it with ${BUILD_DIR}/%
# Since % is fully generic, it will match any file name. Effectively, it will prepend the build directory to the file names.
ALL_THE_ARDUINO_C_O_FILES_NAMES := ${patsubst %,${BUILD_DIR}/%,$(ALL_THE_ARDUINO_C_O_FILES_NAMES)}
ALL_THE_ARDUINO_CPP_O_FILES_NAMES := ${patsubst %,${BUILD_DIR}/%,$(ALL_THE_ARDUINO_CPP_O_FILES_NAMES)}
ALL_THE_ARDUINO_S_O_FILES_NAMES := ${patsubst %,${BUILD_DIR}/%,$(ALL_THE_ARDUINO_S_O_FILE_NAMES)}

# ------------------DEFAULT TARGET------------------#
# This is the default target that gets run when you just type "make" in the terminal.
# It's usually named "all" or "default", but you can name it anything you want.
# I named it banana to show that you don't need to name it "all" or "default" or anything like that.
# It will create the main.elf file, which is the final output of the compilation process.
# What this basically does is that is says "banana runs the main.elf compilation rule", which is defined below.
banana: ${BUILD_DIR}/main.elf

# ------------------BUILD DIRECTORY CREATION------------------#
# This is a rule that creates the build directory if it doesn't exist.
# This means, whenever we put the reference to ${BUILD_DIR} in a rule,
# It will conveniently add the build directory name to the name of the target, but
${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

# ------------------GENERIC COMPILATION------------------#
# Generic Commands where every .c and .cpp gets compiled into a .o file with the same name
# This says we want to make a .o file in the build directory from a specific .c file.
# The % means that whatever the name of the .c file is, .o will have the same name.

# The | ${BUILD_DIR} means that the build directory must be created before this rule is run.
# The | specifically means that even if the BUILD_DIR was recently updated, as long as it exists, it will not be recreated.

# $< means the "first dependency" after the colon. $@ means the "target", or the thing before the colon.
# So in total, this says:
# 1. I have a name of a file I want to dump in build
# 2. I have a .c file that I want to compile into that .o file
# 3. Name the .o file the same as the .c file, but in the build directory.
# 4. Use the command to run the compiler. Give it -I (include) flags from the variable DASH_I_STUFF.
# 5. Use the -c flag to specify we're compiling a source file into an object file.
# 6. The -c flag wants to compile using the "<$" file, which is the first dependency after the colon.
# 7. Output the compiled object file to the target, which is the $@, or the thing before the colon.

${BUILD_DIR}/%.o: %.c | ${BUILD_DIR}
	${THIS_RUNS_THE_COMPILER} ${DASH_I_STUFF} -c $< -o $@ 

${BUILD_DIR}/%.o: %.cpp | ${BUILD_DIR}
	${THIS_RUNS_THE_COMPILER} ${DASH_I_STUFF} -c $< -o $@

${BUILD_DIR}/%.o: %.S | ${BUILD_DIR}
	${THIS_RUNS_THE_COMPILER} ${DASH_I_STUFF} -c $< -o $@

# ------------------MAIN FILE COMPILATION------------------#
# This explicitly generates the main.o file from main.cpp. 
# Theoretically, this is done with the generic %.o: %.cpp rule
# But this is here to show how you can explicitly define a rule for a specific file.

# ${BUILD_DIR}/main.o: main.cpp | ${BUILD_DIR}
# 	${THIS_RUNS_THE_COMPILER} ${DASH_I_STUFF} -c main.cpp -o ${BUILD_DIR}/main.o

# ------------------ARDUINO C AND CPP FILE COMPILATION------------------#
# This compiles all the Arduino C and C++ files into object files.
# It uses something similar to the generic %.o: %.c rule, but since
# the files are in the Arduino directories, we need to specify the full path to the files.
${BUILD_DIR}/%.o: ${DIRECTORY_WHERE_ALL_THE_ARDUINO_C_AND_CPP_FILES_ARE}/%.c | ${BUILD_DIR}
	${THIS_RUNS_THE_COMPILER} ${DASH_I_STUFF} -c $< -o $@ 

${BUILD_DIR}/%.o: ${DIRECTORY_WHERE_ALL_THE_ARDUINO_C_AND_CPP_FILES_ARE}/%.cpp | ${BUILD_DIR}
	${THIS_RUNS_THE_COMPILER} ${DASH_I_STUFF} -c $< -o $@

${BUILD_DIR}/%.o: ${DIRECTORY_WHERE_ALL_THE_ARDUINO_C_AND_CPP_FILES_ARE}/%.S | ${BUILD_DIR}
	${THIS_RUNS_THE_COMPILER} ${DASH_I_STUFF} -c $< -o $@

# ------------------LINKING------------------#
# This links all the .o files together to create the elf file.
# Dependencies are a macro that includes a giant list of .o files, as well as the main file.
# The $^ means "all the dependencies" after the colon, and the $@ means "the target", or the thing before the colon.

# NOTE. $^ is DIFFERENT from $<. 
# The linker needs ALL the .o files, to know what to link together!
${BUILD_DIR}/main.elf: ${BUILD_DIR}/main.o ${ALL_THE_ARDUINO_C_O_FILES_NAMES} ${ALL_THE_ARDUINO_CPP_O_FILES_NAMES} ${ALL_THE_ARDUINO_S_O_FILES_NAMES} | ${BUILD_DIR}
	${THIS_RUNS_THE_COMPILER} $^ -o $@


# ------------------CLEANING------------------#
# This is a clean target that removes all the .o files and the main.elf file.
clean:
	rm -rf ${BUILD_DIR}/*

# ------------------PHONY TARGETS------------------#
# These are phony targets that are not actual files, but just commands to run.
.PHONY: clean print_all print_files print_external_stuff

# ------------------PRINTING VARIABLES------------------#
# This is a print target that prints all the critical variables.
# It is useful for debugging and checking the paths and variables.
print_all: print_files print_external_stuff

print_files:
	@echo "COMPILER_LOCATION: ${THIS_RUNS_THE_COMPILER}"
	@echo "BUILD_DIR: ${BUILD_DIR}"
	@echo "ALL_THE_ARDUINO_C_FILE_NAMES: ${ALL_THE_ARDUINO_C_FILE_NAMES}"
	@echo "ALL_THE_ARDUINO_CPP_FILE_NAMES: ${ALL_THE_ARDUINO_CPP_FILE_NAMES}"
	@echo "ALL_THE_ARDUINO_S_FILE_NAMES: ${ALL_THE_ARDUINO_S_FILE_NAMES}"
	@echo "ALL_THE_ARDUINO_C_O_FILES_NAMES: ${ALL_THE_ARDUINO_C_O_FILES_NAMES}"
	@echo "ALL_THE_ARDUINO_CPP_O_FILES_NAMES: ${ALL_THE_ARDUINO_CPP_O_FILES_NAMES}"
	@echo "ALL_THE_ARDUINO_S_O_FILE_NAMES: ${ALL_THE_ARDUINO_S_O_FILE_NAMES}"

print_external_stuff:
	@echo "EXTERNAL_LIBRARIES: ${EXTERNAL_LIBRARIES}"
	@echo "PIN_ALIASES: ${PIN_ALIASES}"
	@echo "ALL_THE_ARDUINO_C_FILE_LOCATIONS: ${ALL_THE_ARDUINO_C_FILE_LOCATIONS}"
	@echo "ALL_THE_ARDUINO_CPP_FILE_LOCATIONS: ${ALL_THE_ARDUINO_CPP_FILE_LOCATIONS}"