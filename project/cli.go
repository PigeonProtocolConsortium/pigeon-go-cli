package main

import (
	"fmt"
	"os"

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
		addPeer(mHash, blocked)
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
		addPeer(mHash, following)
		fmt.Printf("Following %s\n", mHash)
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
	peerRootCmd.AddCommand(peerListCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
