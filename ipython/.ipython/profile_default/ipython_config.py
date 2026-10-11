# save to: ~/.ipython/profile_default/ipython_config.py
from IPython.terminal.prompts import Prompts
from IPython.terminal.prompts import Token


class Prompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [(Token.Prompt, '>>> ')]

    def continuation_prompt_tokens(self, cli=None, width=None):
        return [(Token.Prompt, '    ')]

    def out_prompt_tokens(self, cli=None):
        return [(Token.Prompt, '')]


c.TerminalInteractiveShell.prompts_class = Prompt
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalIPythonApp.display_banner = False
c.TerminalInteractiveShell.editing_mode = 'vi'
c.InteractiveShellApp.exec_lines.append('%load_ext autoreload')
c.InteractiveShellApp.exec_lines.append('%autoreload 2')
