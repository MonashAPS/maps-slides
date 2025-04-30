#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.8": codly-languages
#import "@preview/touying:0.6.1": config-common, config-page, config-methods, components, touying-slide, touying-slide-wrapper,  touying-slides, utils

#let maps-logo = "./maps-logo.png"

#let title-slide(..args) = touying-slide-wrapper(self => {
	let self = utils.merge-dicts(self, config-page(
		footer: place(center, image(maps-logo, height: 1.2em))
	))
	let info = self.info + args.named()
	touying-slide(
		self: self,
		{
			set align(center + horizon)
			block(text(size: 2em, weight: "bold", info.title))
			if info.subtitle != none {
				block(text(gray, info.subtitle))
			}
			if info.author != none {
				block(info.author)
			}
			if info.date != none {
				block(utils.display-info-date(self))
			}
		},
	)
})

#let slide(
	config: (:),
	repeat: auto,
	setting: body => body,
	composer: auto,
	..bodies,
) = touying-slide-wrapper(self => {
	touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

#let blank-slide(
	config: (:),
	repeat: auto,
	setting: body => body,
	composer: auto,
	..bodies,
) = touying-slide-wrapper(self => {
	let self = utils.merge-dicts(self, config-common(
		subslide-preamble: none
	))
	touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

#let maps-theme(
	aspect-ratio: "16-9",
	..args,
	body,
) = {
	set text(size: 25pt, font: "Inter")
	// fix weird thing where bolding it would make it extrabold
	set strong(delta: 0)
	show strong: set text(weight: "bold")

	show heading.where(level: 1): set text(1.4em)
	show link: it => underline(text(blue, it))

	show: codly-init

	show: touying-slides.with(
		config-page(
			paper: "presentation-" + aspect-ratio,
			footer: self => {
				set text(gray, size: .6em)
				place(
					center,
					grid(
						columns: (1fr, 1fr, 1fr),
						align: horizon,
						image(maps-logo, height: 2em),
						self.info.title,
						[#context utils.slide-counter.display() / #utils.last-slide-number]
					)
				)
			}
		),
		config-common(
			slide-fn: slide,
			preamble: codly(languages: codly-languages),
			subslide-preamble: block(
				below: 1.5em,
				text(1.2em, weight: "bold", utils.display-current-heading(level: 2)),
			),
		),
	..args,
	)

	body
}
