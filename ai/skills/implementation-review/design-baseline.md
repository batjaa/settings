# Design baseline — complexity and deep modules

Distilled from John Ousterhout, _A Philosophy of Software Design_ (2nd ed.). The same two rules as the standards baseline bind it: a documented repo standard or ADR overrides, and every flag is a judgement call.

## The measure

**Complexity is anything that makes a system hard to understand or modify.** It shows up as three symptoms — look for the diff *increasing* any of them:

1. **Change amplification** — a simple change requires edits in many places.
2. **Cognitive load** — how much a developer must know to safely touch this code.
3. **Unknown unknowns** — it isn't obvious which code must change, or what information is needed to change it.

Complexity is incremental: no single check-in ruins a system; hundreds of "just this once" do. Small additions of complexity are still findings.

## Red flags

Each reads *what it is* → *how to fix*; match against the diff:

- **Shallow Module** — an interface nearly as complex as the functionality it hides; it doesn't pay for its existence. → deepen it (more functionality behind the same interface) or inline it away.
- **Information Leakage** — one design decision (a format, a protocol, a schema) reflected in multiple modules, so changing it touches all of them. → give the knowledge one home.
- **Temporal Decomposition** — module structure mirrors the order operations happen (read-then-parse-then-write), not what each piece needs to know. → structure around knowledge, not execution order.
- **Overexposure** — the common case forces callers to learn about rare features (required params that are almost always the same). → default the common case; make special cases opt-in.
- **Pass-Through Method** — a method that does little but forward to another with a similar signature; adjacent layers with similar abstractions. → collapse the layers. Different layer, different abstraction.
- **Pass-Through Variable** — a value threaded through many methods that don't use it. → carry it in a context object owned at the right level.
- **Repetition** — the same nontrivial snippet recurring. → the missing abstraction wants to exist.
- **Special-General Mixture** — special-case code inside a general-purpose mechanism. → push the special case up to the caller or out to the edge; keep the core general.
- **Conjoined Methods** — you can't understand one method without reading another. → redraw the boundary so each is independently understandable.
- **Comment Repeats Code** — the comment adds nothing beyond the names next to it. → comments must add precision (units, ranges, ownership, invariants) or intuition (why, the mental model).
- **Implementation Documentation Contaminates Interface** — interface docs describing internals callers shouldn't know. → split: interface comments say *what*, implementation comments say *how/why*.
- **Vague Name / Hard to Pick Name** — a name too generic to carry meaning ("data", "info", "manager") — and if no precise honest name exists, that's a design problem, not a naming problem.
- **Hard to Describe** — if fully documenting a method or variable takes a long comment, the abstraction is probably wrong.
- **Nonobvious Code** — behaviour a reader can't predict from the code in front of them (hidden coupling, surprising side effects, generic containers standing in for real types). → make it obvious, or document exactly the nonobvious part.

## Principles to weigh

Lenses for judging the shape of the change, not violations:

- **Deep modules.** The best modules have simple interfaces hiding powerful functionality. Prefer fewer, deeper modules over many shallow ones; "classitis" is a cost, not cleanliness.
- **Somewhat general-purpose.** The interface should be general enough to serve tomorrow's second caller; the implementation only today's needs.
- **Pull complexity downwards.** It's better for a module to absorb complexity than to push it onto every caller via config knobs, exceptions, or preconditions.
- **Define errors out of existence.** Prefer semantics where the error case can't occur (deleting a missing file is fine; substring of an out-of-range index returns empty) over throwing and making every caller handle it. Where exceptions remain, aggregate handling rather than scattering it.
- **Better together vs. better apart.** Combine things that share information or are always used together; separate general from special-purpose.
- **Design it twice.** For any new interface in the diff, ask whether an alternative shape was considered; the first idea is rarely the best.
- **Strategic over tactical.** Flag working-but-debt-adding patches — the fix that special-cases instead of addressing the design. Tactical tornadoes leave wreckage.
