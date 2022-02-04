#!/usr/bin/env bash
 
# *********************************************************************** #
#                                                                         #
#  SCRIPT: project.js                                                     #
#  AUTHOR: tomas.canton@student.um.si                                     #
#                                                                         #
#                                                                         #
#                                                                         #
#                                                                         #
#  PROPOSITO: This program is for the managament of projects (create,     #
#             build, run, test) written in C/C++ programming language.    #
#                                                                         #
#                                                                         #
#                                                                         #
#  EXIT CODES:                                                            #
#                                                                         #
#  NOTE: You must have root privileges to execute this script.            #
#                                                                         #
#                                                                         #
# *********************************************************************** #



global_software_name="Project Manager - project.sh"
global_software_version="1.00"
global_sofware_description="This program is for the managament of projects (create, build, run, test) written in C/C++ programming language."

# Author data
global_author_name="Tomás Cantón Cordeiro"
global_author_url="https://github.com/tomascan"
global_author_email="tomas2311@hotmail.com"

# Project Environment
global_project_name=${global_project_name:-}                  # Si no esta definido el nombre del proyecto lo setea como demo.
global_project_directory=${global_project_directory:-`pwd`}   # Si no esta definido el directorio del proyecto lo setea en el path actual.
global_bashrc=${global_bashrc:-project_bashrc}                # Si no esta definido el nombre del bashrc lo setea como project_bashrc
global_project_active=${global_project_active:-0}         # Se activa cuando el proyecto esta activado
global_debug=0



# Crea el Makefile para compilar el proyecto de Hello World!
add_makefile(){

TAB="$(printf '\t')"

echo "IDIR=./include
INSTALLDIR=./bin
SDIR=./src
ODIR=./obj
CC=gcc
CFLAGS=-I\$(IDIR)
OFLAGS=
LIBS=-lm

_DEPS = main.h
DEPS = \$(patsubst %,\$(IDIR)/%,\$(_DEPS))

_OBJ = main.o mainfunc.o
OBJ = \$(patsubst %,\$(ODIR)/%,\$(_OBJ))

.PHONY: all
all: main

\$(ODIR)/%.o: \$(SDIR)/%.c \$(DEPS)
${TAB}@mkdir -p \$(@D)
${TAB}@mkdir -p \$(INSTALLDIR)
${TAB}\$(CC) $(OFLAGS) -c -o \$@ \$< \$(CFLAGS)

main: \$(OBJ)
${TAB}\$(CC) $(OFLAGS) -o \$@ \$^ \$(CFLAGS) \$(LIBS)

.PHONY: install
install:
${TAB}mkdir -p \$(INSTALLDIR)
${TAB}mv main \$(INSTALLDIR)

.PHONY: clean
clean:
${TAB}rm -f \$(ODIR)/*.o *~ core \$(INCDIR)/*~
${TAB}rm -f main
${TAB}rm -f \$(INSTALLDIR)/main
${TAB}rmdir \$(INSTALLDIR) \$(ODIR)" > $1
}

# Crea fichero fuentes del Hello World!
add_sources(){
cat <<EOF >${1}/src/main.c
//
// Ejemplo en https://www.cs.colby.edu/maxwell/courses/tutorials/maketutor/
// 
#include <main.h>

int main() {
  PrintHelloWorld();
  return(0);
}
EOF

cat <<EOF >${1}/src/mainfunc.c 
#include <stdio.h>
#include <main.h>

void PrintHelloWorld(void) {
  printf("Hello World!\n");
  return;
}
EOF

cat <<EOF >${1}/include/main.h
void PrintHelloWorld(void);
EOF

}

# Muestra el usage
usage() {
    echo ""
    echo "$global_software_name v$global_software_version"
    echo ""
    echo ""
    echo "Usage: $0 command"
    echo ""
    echo "Commands:"
    echo "    help [command]                    Displays help for using the program."
    echo "                                      Without a specific command, it only prints a list of all possible commands"
    echo "                                      and their brief descriptions. If you specify a specific command (help, activate,"
    echo "                                      new, add, build, test, or run) then it displays more detailed help for that"
    echo "                                      command (all possible additional command parameters and their use)."
    echo "    new <project name> [-d <path>]    Creates a new project with the given name in the current location."
    echo "                                      use '-d' to give the full path name to the project."
    echo "    activate [-d <path>]              Activates an existing project."
    echo "                                      use '-d' to give the full path name to the project."
    echo "    add <name>                        Adds <name>.h to include/ and <name>.c to src/. It also updates the Makefile if "
    echo "                                      necessary."
    echo "    build [-dr]                       Builds the program inside the project. By default, the program is build in"
    echo "                                      debug mode., but we can modify that with appropriate flags (-d - debug mode,"
    echo "                                      use '-d' to debug mode"
    echo "                                      use '-r' - to release mode"
    echo "    test [-lv] [test name]            Runs tests inside the project."
    echo "                                      use '-l'to displays a list of test names that are in the tests path. Tests are"
    echo "                                      individual scripts named test_<test name>.sh. The command displays only unique names"
    echo "                                      without test_ prefix and .sh extension."
    echo "                                      use '-v' to runs tests using the valgrind command."
    echo "                                      In the case of a given test name (only name of the test can be provided,"
    echo "                                      without the prefix and extension), only the named test is run. Otherwise, all"
    echo "                                      tests are run in alphabetical order."
    echo "    run [parameters]                  Runs the program. Forwards any parameters to the program."
    echo ""
}

# Displays the help
help() {
    [[ $1 != "activate" && $1 != "new" && $1 != "add" && $1 != "build" && $1 != "test" && $1 != "run" ]] && usage && exit

    if [[ $1 == activate ]]; then
        echo ""
        echo "Command activate [-d <path>]"
        echo ""
        echo "  Activates an existing project."
        echo "  use '-d' to give the full path name to the project."
        echo ""
    elif  [[ $1 == new ]]; then
        echo ""
        echo "Command new <project name> [-d <path>]"
        echo ""
        echo "  Creates a new project with the given name in the current location."
        echo "  use '-d' to give the full path name to the project."
        echo ""
    elif  [[ $1 == add ]]; then
        echo ""
        echo "Command add <name>"
        echo ""
        echo "  Adds <name>.h to include/ and <name>.c to src/. It also updates the Makefile if necessary."
        echo ""
    elif  [[ $1 == build ]]; then
        echo ""
        echo "Command build [-dr]"
        echo ""
        echo "  Builds the program inside the project. By default, the program is build in debug mode,"
        echo "  but we can modify that with appropriate flags"
        echo "  use '-d' to debug mode"
        echo "  use '-r' - to release mode"
        echo ""
    elif  [[ $1 == test ]]; then
        echo ""
        echo "Command test [-lv] [test name]"
        echo ""
        echo "  Runs tests inside the project."
        echo "  use '-l'to displays a list of test names that are in the tests path. Tests are"
        echo "  individual scripts named test_<test name>.sh. The command displays only unique names"
        echo "  without test_ prefix and .sh extension."
        echo "  use '-v' to runs tests using the valgrind command. In the case of a given test name"
        echo "  (only name of the test can be provided, without the prefix and extension), only the named"
        echo "  test is run. Otherwise, all tests are run in alphabetical order."
        echo ""
    elif  [[ $1 == run ]]; then
        echo ""
        echo "Command run [parameters]"
        echo ""
        echo "  Runs the program. Forwards any parameters to the program."
        echo ""
    fi
}

# Agregar las funcionalidades de para el autocompletado
add_bashcompletion() {
    global_project_directory=$1

    cat <<EOF >>${global_project_directory}/bash-completion.bash
# Bash-completion
_Project ()
{
  local cur
  COMPREPLY=()
  cur="\${COMP_WORDS[COMP_CWORD]}"
  prev="\${COMP_WORDS[COMP_CWORD-1]}"

  case "\$prev" in
    -d)
        _filedir -d
        return 0
        ;;
    -h|-help)
        return 0
        ;;

    activate|new)
        COMPREPLY=( \$( compgen -W '-d' -- "\$cur" ) )
        return 0
        ;;

    test)
        COMPREPLY=( \$( compgen -W '-l -v' -- "\$cur" ) )
        return 0
        ;;

    help)
        COMPREPLY=( \$( compgen -W "new activate add build run test" -- "\$cur" ) )
        return 0
        ;;

    build)
        COMPREPLY=( \$( compgen -W '-d -r' -- "\$cur" ) )
        return 0
        ;;
  esac

  case "\$cur" in
    -*)
        COMPREPLY=( \$( compgen -W '-d -r -l -v -h --help' -- \$cur ) )
        ;;

    *)
        COMPREPLY=( \$( compgen -W 'help new activate add build run test' -- \$cur ) )
        ;;
  esac

  return 0
}

complete -F _Project -o nospace -o filenames ./project.sh
EOF
}

# Si el project_bashrc personalizado no existe lo crea
add_bashrc() {
    global_project_directory=$1

    if [ ! -f "${global_project_directory}/${global_bashrc}" ]
    then
echo "# Define variables de entorno
export global_project_name=${global_project_name}
export global_project_directory=${global_project_directory}
export global_project_active=1
export PATH=$PATH:`pwd`

# Define el PROMPT del Bash
export PS1=\"[\u@\h (${global_project_name})]$ \"

# Se cambia al directorio del projecto
cd ${global_project_directory}

# Agrega la linea que carga el script bash-completion si existe
[ -f ${global_project_directory}/bash-completion.bash ] && source ${global_project_directory}/bash-completion.bash

echo 'Project ${global_project_name} is active.'" >${global_project_directory}/${global_bashrc}
    fi
}

# Comando NEW
new() {
    global_project_name=$1

    if [[ ! -z $2 ]]; then          # Si el path esta definido lo configuramos.
       global_project_directory=$2/project_${global_project_name}
    else
       global_project_directory=$global_project_directory/project_${global_project_name}
    fi

    # Crea estructura de directorios
    [ ! -d "${global_project_directory}/src" ]     && mkdir -p ${global_project_directory}/src
    [ ! -d "${global_project_directory}/include" ] && mkdir -p ${global_project_directory}/include
    [ ! -d "${global_project_directory}/build" ]   && mkdir -p ${global_project_directory}/build
    [ ! -d "${global_project_directory}/tests" ]   && mkdir -p ${global_project_directory}/tests

    # Crea el Makefile y los fuentes del Hello World!
    add_makefile ${global_project_directory}/Makefile
    add_sources  ${global_project_directory}

    # Crea .bashrc y Bash-Completion
    add_bashcompletion ${global_project_directory}
    add_bashrc ${global_project_directory} 
}


# Activa un proyecto, abriendo un nuevo bash y carga el .bashrc del propio proyecto
activate(){
   global_project_directory=$1
   bash --rcfile ${global_project_directory}/${global_bashrc}
} 

# Funcion main
do_main() {
    # Chequea y valida los argumentos del comando
    [[ $1 != "help" && $1 != "activate" && $1 != "new" && $1 != "add" && $1 != "build" && $1 != "test" && $1 != "run" ]] && usage && exit

    # Comando HELP
    [[ $1 == help ]] && help $2

    # Comando NEW
    # $1  $2           $3 $4
    # new project_name -d path
    #
    if [[ $1 == new ]]; then
        if [[ ! -z $2 && $2 != -d && -z $3 ]]; then          # Crea el proyecto con el nombre y el path por defecto
           new $2 
        elif [[ ! -z $2 && $3 == -d && ! -z $4 ]]; then      # Crea proyecto con el nombre y el path definidos.
	   new $2 $4 
        else                                                 # Cualquier otra opcion muestra el usage.
	   help new && exit
        fi
    fi
 
    # Comando ACTIVATE
    # $1       $2 $3
    # activate -d path
    #
    if [[ $1 == activate ]]; then
        if [[ $2 == -d && ! -z $3 && -d $3 ]]; then          # Activamos el proyecto con el path. Verificamos que este exista con la opcion -d   
           activate $3
        elif [[ $2 == -d && ! -d $3 ]]; then
           echo "Error: The project path doesn't exist."
        else 
           help activate && exit                             # Cualquier otra opcion. Muestra el Usage
        fi
    fi

    # Comando ADD
    # $1  $2 
    # add name
    #
    if [[ $1 == add ]]; then
       if [[ $global_project_active -eq 1 ]]; then
          if [[ ! -z $2 ]]; then                                # Crea los ficheros include/name.h y src/name.c
	     touch $global_project_directory/src/$2.c && echo "File $2.c added in $global_project_directory/src"
             touch $global_project_directory/include/$2.h  && echo "File $2.h added in $global_project_directory/include"
          else
             help add && exit
          fi
       else
          echo "Error: Firts need activate the project."
       fi
    fi

    # Comando BUILD
    # $1    $2
    # build -d|r
    #
    if [[ $1 == build ]]; then
       if [[ -z $2 ]]; then                                # Realiza el build sin -d o -r
          make
       elif [[ $2 == -d ]]; then
             make -d                                      
       elif [[ $2 == -r ]]; then                          
             make OFLAGS=-O3                               # Pasa al Makefile la opcione -O3 optimization more for code size and execution time
       else
          help add && exit
       fi
    fi


    # Comando RUN
    # $1  $2....n
    # run [parameters]
    if [[ $1 == run ]]; then
           shift  # Elimina de los parametros pasados por linea de comando el primero (run) y el resto los pasa al main
       ./main $@
    fi


} # Fin do_main

#
# MAIN
# Do not change anything here. If you want to modify the code, edit do_main()
#
do_main "$@"

exit 0
