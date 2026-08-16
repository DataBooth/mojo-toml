default:
    @just --list

pixi-tasks:
    @pixi task list

run task:
    pixi run {{task}}

test:
    pixi run test-all

build:
    pixi run build-package

examples:
    pixi run examples-all
