class ProblemsController < ApplicationController
	require "open-uri"

	def update

		name = "equality"
		p = Problem.build(name)
		p.valid?

		redirect_to '/problems/new'
	end
end
