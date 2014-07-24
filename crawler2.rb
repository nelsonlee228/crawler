require 'mechanize'
require 'colorize'
require 'launchy'

# specify the search term && search type
JOBNAME                     = "ruby developer"
LOCATION                    = "Vancouver, BC"
# JOBTYPE                     = %w(is_contract is_internship is_parttime)

class Crawler

  def self.work
    loop do
      # define a new array to obtain posting data
      job_posts = Array.new

      # page                        = agent.get('http://vancouver.en.craigslist.ca/jjj/')

      target_list =   [{:title => 'craigslist',   :url => 'http://vancouver.en.craigslist.ca/jjj/'}, 
                       {:title => 'indeed',       :url => 'http://www.indeed.ca/'}]
                        



      target_list.each do |target|
        puts target[:title]
        if target[:title] == 'craigslist'
          #      ___           ___           ___                       ___           ___           ___                   ___           ___     
          #     /\  \         /\  \         /\  \          ___        /\  \         /\  \         /\__\      ___        /\  \         /\  \    
          #    /::\  \       /::\  \       /::\  \        /\  \      /::\  \       /::\  \       /:/  /     /\  \      /::\  \        \:\  \   
          #   /:/\:\  \     /:/\:\  \     /:/\:\  \       \:\  \    /:/\:\  \     /:/\ \  \     /:/  /      \:\  \    /:/\ \  \        \:\  \  
          #  /:/  \:\  \   /::\~\:\  \   /::\~\:\  \      /::\__\  /:/  \:\  \   _\:\~\ \  \   /:/  /       /::\__\  _\:\~\ \  \       /::\  \ 
          # /:/__/ \:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\  __/:/\/__/ /:/__/_\:\__\ /\ \:\ \ \__\ /:/__/     __/:/\/__/ /\ \:\ \ \__\     /:/\:\__\
          # \:\  \  \/__/ \/_|::\/:/  / \/__\:\/:/  / /\/:/  /    \:\  /\ \/__/ \:\ \:\ \/__/ \:\  \    /\/:/  /    \:\ \:\ \/__/    /:/  \/__/
          #  \:\  \          |:|::/  /       \::/  /  \::/__/      \:\ \:\__\    \:\ \:\__\    \:\  \   \::/__/      \:\ \:\__\     /:/  /     
          #   \:\  \         |:|\/__/        /:/  /    \:\__\       \:\/:/  /     \:\/:/  /     \:\  \   \:\__\       \:\/:/  /     \/__/      
          #    \:\__\        |:|  |         /:/  /      \/__/        \::/  /       \::/  /       \:\__\   \/__/        \::/  /                 
          #     \/__/         \|__|         \/__/                     \/__/         \/__/         \/__/                 \/__/                  

          # initialize a new mechanize instance
          agent                       = Mechanize.new
          page                        = agent.get(target[:url])
          # find the search form through element ID
          craig_form                  = page.form_with(:id => "searchform")

          # fill out the search text input with the search term
          craig_form['query']         = JOBNAME

          # if job types for the checkboxes are defined do the following.... else skip..
          if defined?(JOBTYPE) && (JOBTYPE != [])
            JOBTYPE.each do |type|
              craig_form.checkbox_with(:name => type).check
            end
          end

          # submit the search form and get the search result page
          craig_results               = craig_form.submit

          # click on each link in the search result page and obtain the data from the sub page 
          # then construct hashes and put them into the job_posts Array
          loop do
            craig_results.links.each do |link|
              cls = link.attributes.attributes['class']
              if cls && cls.value == 'i'
                sub_page = link.click
                post_link               =     sub_page.uri.to_s
                post_title              =     sub_page.search('h2.postingtitle').text.squeeze(" ").strip 
                post_body               =     sub_page.search('#postingbody').text.squeeze(" ").strip
                post_compensation       =     sub_page.search(".bigattr b").text.squeeze(" ").strip
                post_company            =     nil
                job_posts               <<    {link: post_link, title: post_title, body: post_body, compensation: post_compensation, company: post_company}
              end
            end

            if link = craig_results.link_with(:text => " next > ") # As long as there is still a nextpage link...
              pp link
              craig_results = link.click
            else # If no link left, then break out of loop
              break
            end
          end

        elsif target[:title] == 'indeed'
         #                  ___           ___           ___           ___           ___     
         #      ___        /\__\         /\  \         /\  \         /\  \         /\  \    
         #     /\  \      /::|  |       /::\  \       /::\  \       /::\  \       /::\  \   
         #     \:\  \    /:|:|  |      /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/\:\  \  
         #     /::\__\  /:/|:|  |__   /:/  \:\__\   /::\~\:\  \   /::\~\:\  \   /:/  \:\__\ 
         #  __/:/\/__/ /:/ |:| /\__\ /:/__/ \:|__| /:/\:\ \:\__\ /:/\:\ \:\__\ /:/__/ \:|__|
         # /\/:/  /    \/__|:|/:/  / \:\  \ /:/  / \:\~\:\ \/__/ \:\~\:\ \/__/ \:\  \ /:/  /
         # \::/__/         |:/:/  /   \:\  /:/  /   \:\ \:\__\    \:\ \:\__\    \:\  /:/  / 
         #  \:\__\         |::/  /     \:\/:/  /     \:\ \/__/     \:\ \/__/     \:\/:/  /  
         #   \/__/         /:/  /       \::/__/       \:\__\        \:\__\        \::/__/   
         #                 \/__/         ~~            \/__/         \/__/         ~~       

          # initialize a new mechanize instance
          agent                       = Mechanize.new

          page                        = agent.get(target[:url])
          # find the search form through element ID
          indeed_form                 = page.form_with(:name => "jobsearch")

          # fill out the search text input with the search term
          indeed_form['q']        = JOBNAME
          indeed_form['l']        = LOCATION

          # submit the search form and get the search result page
          indeed_results              = indeed_form.submit

          # click on each link in the search result page and obtain the data from the sub page 
          # then construct hashes and put them into the job_posts Array
          loop do
            indeed_results.search(".row").each do |row|
              # pp row
              post_link               =     row.css('a')[0]['href']
              post_title              =     row.css('a')[0].text
              post_body               =     row.css('.snip .summary')[0].text.squeeze(" ").strip
              post_body
              post_compensation       =     nil
              post_company            =     row.css(".company").text.squeeze(" ").strip || row.css(".company span").text.squeeze(" ").strip
              # pp post_company
              job_posts               <<    {link: post_link, title: post_title, body: post_body, compensation: post_compensation, company: post_company}
            end

            if link = indeed_results.link_with(:text => "Next »") # As long as there is still a nextpage link...
              indeed_results = link.click
            else # If no link left, then break out of loop
              break
            end
          end

        end

      end
      job_posts.each_with_index do |post, index|
        puts index.to_s.colorize(:green)
        post.each do |key, value|
          puts key.to_s.colorize(:yellow) << ":\s" << value.to_s
        end
      end
      # puts job_posts.count

      sleep 15
    end
  end

end

Crawler.work
