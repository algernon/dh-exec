## -*- shell-script -*-

load "test.lib"

run_dh_exec_illiterate () {
        run_dh_exec_with_input <<EOF
#! ${top_builddir}/src/dh-exec-illiterate
Greetings, my dear reader, and welcome to the awesome world of literate programming!

Today, we're going to explore how to write a debhelper install file in
a literate manner. Trust me, it's going to be lots and lots of fun!

So, what exactly are we trying to accomplish? We're going to try
installing a file from \`src/this-file' in the source tree, to a
multi-arched path in the binary file. Lets say, to
\`/usr/lib/foo/\${DEB_HOST_MULTIARCH}/'.

Of course, \${DEB_HOST_MULTIARCH} is a variable, and will be expanded
later in the dh-exec pipeline. It'll be something like
x86_64-linux-gnu.

Furthermore, we want to install all files from the 'usr/lib' directory
under debian/tmp. If we were writing an illiteral install file, we'd
write this rule as:

    usr/lib

But the above description is much easier to understand, isn't it?

We're almost finished! One thing left to do, is to install a script
named \`rename-me', to \`/usr/share/foo/new-name' - we renamed it in
the process!
EOF
}

@test "illiterate: The literate text gets removed" {
        run_dh_exec_illiterate

        ! expect_output "Greetings, my dear reader"
}

@test "illiterate: the good stuff is left in" {
        run_dh_exec_illiterate

        expect_output "usr/lib"
}

@test "illiterate: rename construct is recognised" {
        run_dh_exec_illiterate

        expect_output "rename-me => /usr/share/foo/new-name"
}

@test "illiterate: normal file copy is recognised" {
        run_dh_exec_illiterate

        expect_output "src/this-file /usr/lib/foo/\${DEB_HOST_MULTIARCH}/"
}
