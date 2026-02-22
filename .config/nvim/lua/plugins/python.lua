return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				basedpyright = {},
				pyright = { enabled = false },
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = { "basedpyright" },
		},
	},
}
