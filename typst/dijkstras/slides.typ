#import "@preview/codly:1.3.0"
#import "@preview/fletcher:0.5.7": diagram, edge, hide,node
#import "@preview/pinit:0.2.2": pin, pinit-arrow, pinit-highlight, pinit-point-from
#import "@preview/touying:0.6.1": components, config-info, pause, utils, touying-reducer
#import "../template.typ": blank-slide, maps-theme, slide, title-slide

#let diagram = touying-reducer.with(reduce: diagram, cover: hide)

#show: maps-theme.with(config-info(
	title: [Dijkstra’s Algorithm],
	author: [Lauren Yim],
))

#title-slide[]

#blank-slide(repeat: 2, self => [
	#let (alternatives,) = utils.methods(self)
	#place(center + horizon, image(alternatives("dijkstra-wikipedia.png", "dijkstra-wikipedia-annotated.png")))
])

== Dijkstra's Algorithm

#let src = red
#let src-stroke = (paint: src, thickness: 2pt)

#let adj_ = blue
#let curr = green.lighten(50%)
#let adj = adj_.lighten(50%)
#let vis = gray.lighten(50%)
#let n = node.with(radius: 0.8em)
#let graph = diagram.with(node-shape: circle, node-stroke: 1pt, label-size: .8em, label-sep: 3pt)
#let example-graph-node-pos(i) = (rel: (90deg + i/5 * 360deg, 10em), to: <0>)

#grid(
	columns: 2,
	gutter: 1em,
	[Dijkstra's algorithm is a method for finding the shortest distance between a #underline(stroke: src-stroke)[source node] in a graph and all other nodes.],
	graph({
		n((0, 0), name: <0>)
		n(example-graph-node-pos(1), name: <1>, stroke: src-stroke)
		n(example-graph-node-pos(2), name: <2>)
		n(example-graph-node-pos(3), name: <3>)
		n(example-graph-node-pos(4), name: <4>)
		n(example-graph-node-pos(5), name: <5>)

		edge(<1>, <0>, 5)
		edge(<2>, <0>, 1)
		edge(<3>, <0>, 5)
		edge(<4>, <0>, 3)
		edge(<5>, <0>, 2)
		edge(<2>, <3>, 5, label-side: right)
		edge(<3>, <4>, 1, label-side: right)
		edge(<4>, <5>, 7)
		edge(<5>, <1>, 1)
	})
)

== Basic Algorithm

#slide(repeat: 11, self => [
	#let (only, uncover) = utils.methods(self)

	#grid(
		columns: 2,
		gutter: 1em,
		[
			#set text(.8em)
			While there are unvisited nodes:
			- Get the #highlight(fill: curr)[unvisited node with the smallest distance]
			- Update the distances of the #highlight(fill: adj)[adjacent nodes]
			- Mark the node as #highlight(fill: vis)[visited]
		],
		graph({
			n((0, 0), name: <0>,
				only(1, sym.infinity) + only("2-3", [5]) + only("4-", [3]),
				fill: only("2,4", adj) + only("5-6", curr) + only("7-", vis)
			)
			n(example-graph-node-pos(1), name: <1>,
				[0],
				fill: only("1-2", curr) + only("3-", vis),
				stroke: src-stroke
			)
			n(example-graph-node-pos(2), name: <2>,
				only("1-5", sym.infinity) + only("6-", [4]),
				fill: only(6, adj) + only(7, curr) + only("8-", vis)
			)
			n(example-graph-node-pos(3), name: <3>,
				only("1-5", sym.infinity) + only("6-8", [8]) + only("9-", [7]),
				fill: only("6,9", adj) + only(10, curr) + only(11, vis)
			)
			n(example-graph-node-pos(4), name: <4>,
				only("1-3", sym.infinity) + only("4-5", [8]) + only("6-", [6]),
				fill: only("4,6", adj) + only("8-9", curr) + only("10-", vis)
			)
			n(example-graph-node-pos(5), name: <5>,
				only(1, sym.infinity) + only("2-", [1]),
				fill: only(2, adj) + only("3-4", curr) + only("5-", vis)
			)

			let e(from, to, w, i: none, ..args) = {
				let col = if i == none {
					black
				} else {
					only("1-" + str(i - 1) + "," + str(i + 1) + "-", black) + only(str(i), adj_)
				}
				edge(from, to, ..args.pos(), ..args.named(), text(fill: col, [#w]), stroke: col)
			}
			e(<1>, <0>, 5, i: 2)
			e(<2>, <0>, 1, i: 6)
			e(<3>, <0>, 5, i: 6)
			e(<4>, <0>, 3, i: 6)
			e(<5>, <0>, 2, i: 4)
			e(<2>, <3>, 5, label-side: right)
			e(<3>, <4>, 1, i: 9, label-side: right)
			e(<4>, <5>, 7, i: 4)
			e(<5>, <1>, 1, i: 2)
		})
	)
])

== Why does this work?

#slide(repeat: 4, self => [
	#let (only, uncover) = utils.methods(self)
	#grid(
		columns: 2,
		gutter: 1em,
		[
			#set text(0.7em)
			- Let's consider a particular iteration. Why is is it valid to visit that node and 'lock in' its distance?
			#uncover("2-")[- Because every other unvisited node has a greater or equal distance, there's no way to use those nodes to reach the green node at a smaller distance]
			#uncover("3-")[
			- What are we implicitly assuming here?
					#uncover("4-")[
					- Traversing more edges cannot decrease the distance
					- There are no negative edge weights
			]]
		],
		only("1-", graph({
			n((0, 0), name: <0>, [3], fill: curr)
			n(example-graph-node-pos(1), name: <1>, [0], fill: vis, stroke: src-stroke)
			n(example-graph-node-pos(2), name: <2>, sym.infinity)
			n(example-graph-node-pos(3), name: <3>, sym.infinity)
			n(example-graph-node-pos(4), name: <4>, [8])
			n(example-graph-node-pos(5), name: <5>, [1], fill: vis)

			let e(from, to, w, i: none, ..args) = {
				let col = if i == none {
					black
				} else {
					only("1-" + str(i - 1) + "," + str(i + 1) + "-", black) + only(str(i), adj_)
				}
				edge(from, to, ..args.pos(), ..args.named(), text(fill: col, [#w]), stroke: col)
			}
			edge(<1>, <0>, 5)
			edge(<2>, <0>, 1)
			edge(<3>, <0>, 5)
			edge(<4>, <0>, 3)
			edge(<5>, <0>, 2)
			edge(<2>, <3>, 5, label-side: right)
			edge(<3>, <4>, 1, label-side: right)
			edge(<4>, <5>, 7)
			edge(<5>, <1>, 1)
		})
	))
])

== Negative Edge Weights

#components.side-by-side(
	[
		=== Dijkstra's

		#v(2em)
		#place(center, graph({
			n((0, 0), name: <0>, [0], stroke: src-stroke)
			n((rel: (60deg, 10em), to: <0>), [3], name: <1>)
			n((rel: (0deg, 10em), to: <0>), [2], name: <2>)
			edge(<0>, <1>, 3)
			edge(<0>, <2>, 2)
			edge(<1>, <2>, -2)
		}))
	],
	[
		=== Correct Distances

		#v(2em)
		#place(center, graph({
			n((0, 0), name: <0>, [0], stroke: src-stroke)
			n((rel: (60deg, 10em), to: <0>), [0], name: <1>)
			n((rel: (0deg, 10em), to: <0>), [1], name: <2>)
			edge(<0>, <1>, 3)
			edge(<0>, <2>, 2)
			edge(<1>, <2>, -2)
		}))
	]
)

== Implementation Details

#[#set text(0.7em)
While there are unvisited nodes:
- #pin(1)Get the unvisited node with the smallest distance#pin(2)
- Update the distances of the adjacent nodes
- Mark the node as visited
#pause
#pinit-highlight(dy: -0.5em, extended-height: 1em, 1, 2)
#pinit-point-from(2)[How do we actually do this?]
#pause
We use a data structure called a *heap*.
]

== Heaps (Priority Queues)

#[#set text(0.9em)
Heaps store a collection of sortable objects and allow you to:
- *Push:* add an object onto the heap
- *Pop:* get and remove the smallest (or largest) object in the heap
all in $cal(O)(log n)$ time.

If we store nodes in the heap, then we can easily get the one with the smallest distance efficiently.
]

---

#[#set text(0.8em)
Python's heap is a *min* heap.

```py
import heapq

heap = []

heapq.heappush(heap, 2)
heapq.heappush(heap, 1)

heapq.heappop(heap) # Returns 1
```]

== Adjacency List

#grid(
	columns: 2,
	gutter: 1em,
	[
		#set text(0.7em)
		```py
		graph = [
			[(1, 1), (2, 5)],
			[(0, 1), (2, 2), (3, 7)],
			[(0, 5), (1, 2), (3, 3), (4, 1), (5, 5)],
			[(1, 7), (2, 3), (5, 1)],
			[(2, 1), (5, 5)],
			[(2, 5), (3, 1), (4, 5)]
		]
		```
	],
	graph({
		n((0, 0), name: <0>, [2])
		n(example-graph-node-pos(1), name: <1>, [0], stroke: src-stroke)
		n(example-graph-node-pos(2), name: <2>, [4])
		n(example-graph-node-pos(3), name: <3>, [5])
		n(example-graph-node-pos(4), name: <4>, [3])
		n(example-graph-node-pos(5), name: <5>, [1])

		edge(<1>, <0>, 5)
		edge(<2>, <0>, 1)
		edge(<3>, <0>, 5)
		edge(<4>, <0>, 3)
		edge(<5>, <0>, 2)
		edge(<2>, <3>, 5, label-side: right)
		edge(<3>, <4>, 1, label-side: right)
		edge(<4>, <5>, 7)
		edge(<5>, <1>, 1)
	})
)

== Reading Graphs

#slide(repeat: 2, self => [
	#let (only,) = utils.methods(self)

	#let size = 0.7em
	#grid(
		columns: (1fr, 2fr),
		gutter: 1em,
		{
			set text(size)
			codly.local(number-format: none)[
				```
				6 9
				1 2 1
				1 3 5
				2 3 2
				2 4 7
				3 4 3
				3 5 1
				3 6 5
				4 6 1
				5 6 5
				```
			]
		},
		[
			#only(1, place(center, graph({
				n((0, 0), name: <0>, [3])
				n(example-graph-node-pos(1), name: <1>, [1])
				n(example-graph-node-pos(2), name: <2>, [3])
				n(example-graph-node-pos(3), name: <3>, [6])
				n(example-graph-node-pos(4), name: <4>, [4])
				n(example-graph-node-pos(5), name: <5>, [2])

				edge(<1>, <0>, 5)
				edge(<2>, <0>, 1)
				edge(<3>, <0>, 5)
				edge(<4>, <0>, 3)
				edge(<5>, <0>, 2)
				edge(<2>, <3>, 5, label-side: right)
				edge(<3>, <4>, 1, label-side: right)
				edge(<4>, <5>, 7)
				edge(<5>, <1>, 1)
			})))
			#only(2)[
				#set text(size)
				```py
				n, m = map(int, input().split())
				graph = [[] for _ in range(n)]
				for _ in range(m):
					from_, to, weight = map(int, input().split())
					# Adjusting from 1-indexing to 0-indexing
					from_ -= 1
					to -= 1
					graph[from_].append((to, weight))
					graph[to].append((from, weight))
				```
			]
		]
	)
])

== Dijkstra's Algorithm Implementation

#let impl = [#set text(0.419em)
```py
import heapq

# None indicates ∞ (the node has not been visited yet)
distances: list[int | None] = [None for _ in range(len(graph))]
# heap contains tuples (distance, node)
heap = [(0, 0)] # Start at node 0 with distance 0
distances[0] = 0

while heap:
	distance, current = heapq.heappop(heap)
	# Skip nodes that already have a better distance
	if distance > distances[current]:
		continue

	for next, weight in graph[current]:
		new_distance = distance + weight
		if distances[next] is None or new_distance < distances[next]:
			distances[next] = new_distance
			heapq.heappush(heap, (new_distance, next))
```]

#impl

== Complexity

#grid(
	columns: (3fr, 4fr),
	gutter: 1em,
	[
		#set text(0.675em)
		- We have $V$ vertices (nodes) and $E$ edges.
		- We insert into the heap at most twice for each edge in the graph: $cal(O)(E log E)$
		- There are at most $V^2$ edges (in a simple graph):
			$
			&&& cal(O)(E log E) \
			&=&& cal(O)(E log(V^2)) \
			&=&& cal(O)(2 E log V) \
			&=&& cal(O)(E log V) \
			$
	],
	impl,
)

== Contest

- Contest: #link("https://judge.monashaps.com/contest/2025s1w9")[judge.monashaps.com/contest/2025s1w9]
- Slides and code: #link("https://monashaps.com/discord")[monashaps.com/discord]
