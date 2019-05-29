# JIRA-Ticket-Number: Brief Summary of ticket
#
class Jobs::NameOfThisSheetWriteJob < Jobs::Base

	# Called by location- include description if necessary
	# Brief description of what this action does
	def perform(test=false)
		data_arr = ["header1", "header2", "header3", "header4"]

		query = get_query(test)
		results = ModelName.find_by_sql(query)

		results.each {|row| row.nil? ? next : data_arr.push([row.data1, row.data2, row.data3, row.data4]) }

		# remove if we can use ~/.rvm/gems/ruby-2.3.3/gems/google-api-client-0.28.4/generated/google/apis/sheets_v4/service.rb#clear_values
		while data_arr.size < 30 do
			data_arr.push([".", "", "", ""])
		end

		begin
			Google.write_example_sheet(data_arr)
		rescue Exception => e
			Rails.logger.error("NameOfThisSheetWriteJob.perform: #{e.message}\n#{e.backtrace.join('\n')}")
		end
	end

	# for when the query is beyond ActionRecord
	def get_query(test)
		today = test ? "CURRENT_DATE() - INTERVAL 100 DAY" : "CURRENT_DATE()"
		query = <<-SQL
			SELECT
				DISTINCT DATE_FORMAT(DATE(day), '%m/%d/%Y') AS date,
				ROUND(SUM(IF(COALESCE(one_thing, another_thing) = 'title', value_name, 0.0)), 2) AS one_thing_costs,
				ROUND(SUM(IF(COALESCE(two_thing, another_thing) = 'title', value_name, 0.0)), 2) AS two_thing_costs
				notes as valid_notes
			FROM
				main_table as mt
			LEFT JOIN other_table as ot ON mt.cid = ot.cid
			LEFT JOIN extra_table as et ON mt.afid = et.afid
			WHERE 1 = 1
			AND
				CASE
					WHEN DAY(#{today}) = 1 
						THEN (DATE(day) BETWEEN DATE_SUB(DATE_FORMAT(#{today}, '%Y-%m-01'), INTERVAL 1 MONTH) AND DATE_FORMAT(LAST_DAY(CURRENT_DATE - INTERVAL 1 MONTH), '%Y-%m-%d'))
					WHEN DAY(#{today}) <> 1 
						THEN (DATE(day) BETWEEN DATE_FORMAT(#{today}, '%Y-%m-01') AND DATE_SUB(#{today}, INTERVAL 1 DAY))
				END
			GROUP BY 1
		SQL
		query
	end

	# get the Environment keys, handy while in a scheduled/resque state
	def dump_env
		Rails.logger.info(ENV.keys.to_s)
	end

end
