package main

import (
	"fmt"
	"os"
	"path"

	"github.com/spf13/cobra"
)

// CLI: `pigeon`
var rootCmd = &cobra.Command{
	Use:   "pigeon",
	Short: "Pigeon is a peer-to-peer database for offline systems.",
	Long: `Pigeon is an off-grid, serverless, peer-to-peer
	database for building software that works on poor internet
	connections, or entirely offline.`,
	Run: func(cmd *cobra.Command, args []string) {
	},
}

// CLI: `pigeon version`
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the software version.",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Pigeon CLI Client (Golang), version %s\n", Version)
	},
}

// CLI: `pigeon identity`
var identityRootCmd = &cobra.Command{
	Use:   "identity",
	Short: "Identity related commands",
	Run: func(cmd *cobra.Command, args []string) {
	},
}

// CLI: `pigeon identity create`
var identityCreateCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a new identity.",
	Long:  `Creates a new identity.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(createOrShowIdentity())
	},
}

// CLI: `pigeon identity show`
var identityShowCmd = &cobra.Command{
	Use:   "identity",
	Short: "Show current user identity.",
	Long: `Prints the current Pigeon identity to screen. Prints 'NONE' if
	not found.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(showIdentity())
	},
}

// CLI: `pigeon peer`
var peerRootCmd = &cobra.Command{
	Use:     "peer(s)",
	Short:   "Peer related commands",
	Aliases: []string{"peer", "peers"},
	Run: func(cmd *cobra.Command, args []string) {
	},
}

var peerBlockCmd = &cobra.Command{
	Use:   "block",
	Short: "Block a peer from your local node.",
	Run: func(cmd *cobra.Command, args []string) {
		mHash := validateMhash(args[0])
		setPeerStatus(mHash, blocked)
		fmt.Printf("Blocked %s\n", mHash)
	},
}

var peerListCmd = &cobra.Command{
	Use:   "list",
	Short: "show a list of peers by their status (blocked, following, etc..)",
	Run: func(cmd *cobra.Command, args []string) {
		for _, peer := range listPeers() {
			fmt.Printf("%s %s\n", peer.mhash, peer.status)
		}
	},
}

var peerFollowCmd = &cobra.Command{
	Use:   "follow",
	Short: "Follow a peer and replicate their feed when possible.",
	Run: func(cmd *cobra.Command, args []string) {
		mHash := validateMhash(args[0])
		setPeerStatus(mHash, following)
		fmt.Printf("Following %s\n", mHash)
	},
}

var peerUntrackCmd = &cobra.Command{
	Use:     "untrack",
	Short:   "Stop following/blocking a peer",
	Aliases: []string{"unblock", "unfollow"},
	Run: func(cmd *cobra.Command, args []string) {
		mHash := validateMhash(args[0])
		removePeer(mHash)
		fmt.Printf("Untracked %s\n", mHash)
	},
}

// CLI: `pigeon identity`
var blobRootCmd = &cobra.Command{
	Use:     "file(s)",
	Short:   "File related commands",
	Aliases: []string{"file", "blob", "files", "blobs"},
	Run: func(cmd *cobra.Command, args []string) {
	},
}

var blobAddCommand = &cobra.Command{
	Use:     "add",
	Short:   "Begin tracking a file in the database. Provide a pipe or file path.",
	Aliases: []string{"create"},
	Run: func(cmd *cobra.Command, args []string) {
		tpl := "%s\n"
		var output string
		if len(args) == 0 {
			output = addBlobFromPipe(os.Stdin)
		} else {
			mhash, data := getMhashForFile(args[0])
			output = addBlob(mhash, data)
		}
		fmt.Printf(tpl, output)
	},
}

var blobFindCommand = &cobra.Command{
	Use:     "find",
	Short:   "Print the file path of a blob (if any) to STDOUT",
	Aliases: []string{"show"},
	Run: func(cmd *cobra.Command, args []string) {
		p, f := pathAndFilename(args[0])
		fullPath := path.Join(p, f)
		if _, err := os.Stat(fullPath); !os.IsNotExist(err) {
			fmt.Printf("%s\n", fullPath)
		}
	},
}

var bundleCommand = &cobra.Command{
	Use:   "bundle",
	Short: "Operations relating to 'bundles'- a package of information provided by peers",
	Run: func(cmd *cobra.Command, args []string) {
	},
}

var bundleIngestCommand = &cobra.Command{
	Use:   "ingest",
	Short: "consume a bundle into the local database",
	Run: func(cmd *cobra.Command, args []string) {
		panic("Work in progress.")
	},
}

// BootstrapCLI wires up all the relevant commands.
func BootstrapCLI() {
	rootCmd.AddCommand(versionCmd)

	rootCmd.AddCommand(identityRootCmd)
	identityRootCmd.AddCommand(identityShowCmd)
	identityRootCmd.AddCommand(identityCreateCmd)

	rootCmd.AddCommand(peerRootCmd)
	peerRootCmd.AddCommand(peerBlockCmd)
	peerRootCmd.AddCommand(peerFollowCmd)
	peerRootCmd.AddCommand(peerUntrackCmd)
	peerRootCmd.AddCommand(peerListCmd)

	rootCmd.AddCommand(blobRootCmd)
	blobRootCmd.AddCommand(blobAddCommand)
	blobRootCmd.AddCommand(blobFindCommand)

	rootCmd.AddCommand(bundleCommand)
	bundleCommand.AddCommand(bundleIngestCommand)
	err := rootCmd.Execute()
	check(err, "Failed to load CLI: %s", err)
}
