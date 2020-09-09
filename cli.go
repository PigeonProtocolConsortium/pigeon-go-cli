package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "pigeon",
	Short: "Pigeon is a peer-to-peer database for offline systems.",
	Long: `Pigeon is an off-grid, serverless, peer-to-peer
	database for building software that works on poor internet
	connections, or entirely offline.`,
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the software version.",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Pigeon CLI Client (Golang), version %s\n", Version)
	},
}

var createCmd = &cobra.Command{
	Use:   "create [resource]",
	Short: "Create various resources",
	Long:  `Creates resources, such as identities, drafts, messages, blobs, etc..`,
}

var createIdentityCmd = &cobra.Command{
	Use:   "identity",
	Short: "Create a new identity.",
	Long:  `Creates a new identity.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(createOrShowIdentity())
	},
}

// BootstrapCLI wires up all the relevant commands.
func BootstrapCLI() {
	createCmd.AddCommand(createIdentityCmd)
	rootCmd.AddCommand(versionCmd)
	rootCmd.AddCommand(createCmd)
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
