class ProblemsController < ApplicationController
	require "open-uri"

	def new
		@errors = []
		@created = []
		@updated = []
	end

	def update
		Problem.update_concepts
		@created = []
		@updated = []
		names = Problem.get_names
		for name in names
			p = Problem.find_by(name: name)
			if !p
				p = Problem.build(name)
				@created.push(name)
			else
				changed = p.update
				if changed
					@updated.push(name)
				end
			end
			valid, @errors = p.valid_code?
			if valid
				p.save
			end
		end
		render '/problems/new'
	end

	def show
		@problem = Problem.find(params[:id])
	end
end
