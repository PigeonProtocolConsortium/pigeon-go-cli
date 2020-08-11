package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var createCmd = &cobra.Command{
	Use:     "create",
	Short:   "Create various resources (identity, drafts, blob)",
	Aliases: []string{"make", "new"},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("create called")
	},
}

var identityCmd = &cobra.Command{
	Use:     "identity",
	Short:   "Create a new pigeon identity",
	Aliases: []string{"id"},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("create `identity` called")
	},
}

func init() {
	rootCmd.AddCommand(createCmd)
	createCmd.AddCommand(identityCmd)
}
