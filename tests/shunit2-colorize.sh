# shunit2-colorize. Add colors to shUnit2 output.
# By Joel Purra, https://joelpurra.com/

# Based on maven-antsy-color by Julian Simpson, "The Build Doctor", https://www.build-doctor.com/
# https://github.com/builddoctor/maven-antsy-color
# Julian Simpson thanks: Bernd Jünger, https://bjuenger.de/ for https://blog.blindgaenger.net/colorize_maven_output.html
# Julian Simpson thanks: https://johannes.jakeapp.com/blog/category/fun-with-linux/200901/maven-colorized


# Colorize shUnit2 Output.
function colorizeShUnit2() {
    local BLUE="[0;34m"
    local RED="[0;31m"
    local LIGHT_RED="[1;31m"
    local LIGHT_GRAY="[0;37m"
    local LIGHT_GREEN="[1;32m"
    local LIGHT_BLUE="[1;34m"
    local LIGHT_CYAN="[1;36m"
    local YELLOW="[1;33m"
    local WHITE="[1;37m"
    local NO_COLOUR="[0m"

    sed \
        -e "s/^\(Ran \)\([[:digit:]]*\)\( tests*\.\)$/\1${LIGHT_BLUE}\2${NO_COLOUR}\3/g" \
        -e "s/^\(ASSERT:\)\(.*\)/${RED}\1${NO_COLOUR}\2/g" \
        -e "s/^\(FAILED\)\( .failures=\)\([[:digit:]]*\)\(.\)/${RED}\1${NO_COLOUR}\2${RED}\3${NO_COLOUR}\4/g" \
        -e "s/^OK$/${LIGHT_GREEN}&${NO_COLOUR}/g"
}


# TODO: separate and enable alias.
# alias shunit2_uncolored="command shunit2"
#
# function colorizedShUnit2 {
#     source shunit2 | colorizeShUnit2
#     return $PIPESTATUS
# }
#
# alias shunit2=colorizedShUnit2
