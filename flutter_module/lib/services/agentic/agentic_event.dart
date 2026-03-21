/// Events emitted by the agentic loop for UI consumption.
sealed class AgentEvent {
  const AgentEvent();
}

/// Text delta from Claude's response — display incrementally.
class AgentTextDelta extends AgentEvent {
  final String text;
  const AgentTextDelta(this.text);
}

/// Claude requested a tool call — tool execution starting.
class AgentToolStart extends AgentEvent {
  final String toolName;
  final String toolId;
  final Map<String, dynamic> input;
  const AgentToolStart(this.toolName, this.toolId, this.input);
}

/// Tool execution completed — show result.
class AgentToolResult extends AgentEvent {
  final String toolId;
  final String toolName;
  final String output;
  final bool isError;
  const AgentToolResult(this.toolId, this.toolName, this.output,
      {this.isError = false});
}

/// WAL intention logged before tool execution — display intention text above tool card.
class AgentWalEntry extends AgentEvent {
  final String intention;
  final String toolName;
  final int walId;

  const AgentWalEntry(this.intention, this.toolName, this.walId);
}

/// Agentic session completed successfully.
class AgentComplete extends AgentEvent {
  final int totalInputTokens;
  final int totalOutputTokens;
  final int iterationCount;
  final double costUsd;
  const AgentComplete(
      this.totalInputTokens, this.totalOutputTokens, this.iterationCount, this.costUsd);
}

/// Agentic session ended with error.
class AgentError extends AgentEvent {
  final String message;
  const AgentError(this.message);
}
