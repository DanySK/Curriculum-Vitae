#!/usr/bin/env kscript
if (args.size == 0) {
    println("No baseline for computing version")
    System.exit(1)
} else {
    println(args.joinToString(separator = "").replace(':', '_').replace('+', '_'))
}
