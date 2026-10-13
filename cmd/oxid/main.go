// Command oxid is an EXAMPLE private backing CLI co-located in the origin.
//
// A skill declares it needs this tool via `[[requires]] tool = "oxid"` in its
// skill.toml; because oxid is built and released from THIS repo, that requires
// entry resolves to this binary's own release stream (oxid-v*). The skill and
// the tool version together and release together — the co-location the whole
// origin design is built around (architecture.md §1, §8).
//
// Replace this with your real CLI, or delete cmd/oxid/ if you have none yet.
package main

import (
	"fmt"
	"os"
)

// version is stamped at build time by goreleaser (see .goreleaser.yaml ldflags).
var version = "dev"

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "version") {
		fmt.Printf("oxid %s\n", version)
		return
	}
	fmt.Fprintln(os.Stderr, "oxid: example backing CLI. Try: oxid --version")
}
