class ProblemsController < ApplicationController
	require "open-uri"

	def update
		puts '---------------------------------------'
		puts '---------------------------------------'
		puts 'testasdf'
		puts '---------------------------------------'
		puts '---------------------------------------'

		python_url = "https://raw.github.com/cmobrien/superurop/master/problems/equality/equality.py"
		python = open(python_url).read()

		java_url = "https://raw.github.com/cmobrien/superurop/master/problems/equality/equality.java"
		java = open(java_url).read()

		test_url = "https://raw.github.com/cmobrien/superurop/master/problems/equality/equality_tests.java"
		tests = open(test_url).read()

		problem_url = "https://raw.github.com/cmobrien/superurop/master/problems/equality/equality.txt"
		problem = open(problem_url).read()

		puts python
		puts java
		puts tests
		puts problem

		redirect_to '/problems/new'
	end
end
