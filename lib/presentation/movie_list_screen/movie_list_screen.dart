import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_cine_marquee_app_bar.dart';
import '../../widgets/custom_image_view.dart';
import 'models/movie_list_model.dart';
import 'provider/movie_list_provider.dart';
import 'widgets/movie_card_widget.dart';

class MovieListScreen extends StatefulWidget {
  MovieListScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<MovieListProvider>(
      create: (context) => MovieListProvider()..initialize(),
      child: MovieListScreen(),
    );
  }

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      appBar: CustomCineMarqueeAppBar(
        titleText: 'CINE BOOKING',
        onLeadingTap: () {},
        onActionTap: () {},
      ),
      body: Consumer<MovieListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.filteredMovies.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSection(context, provider),
                _buildMovieGrid(context, provider),
                if (provider.isLoading) _buildLoadingIndicator(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, MovieListProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.screenBackground,
        border: Border(
          bottom: BorderSide(color: appTheme.color19A48B, width: 1.h),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF888888).withAlpha(128),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(context, provider),
          SizedBox(height: 16.h),
          _buildCinemaSelector(context, provider),
          SizedBox(height: 16.h),
          _buildDateSelector(context, provider),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, MovieListProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: TextFormField(
        controller: provider.searchController,
        onChanged: provider.onSearchChanged,
        style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
          color: appTheme.gray_500,
        ),
        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            color: appTheme.color7FA48B,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(10.h),
            child: CustomImageView(
              imagePath: ImageConstant.imgSearch,
              height: 16.h,
              width: 14.h,
              fit: BoxFit.contain,
            ),
          ),
          filled: true,
          fillColor: appTheme.gray_900_02,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(color: appTheme.color33FFB3, width: 1.h),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(color: appTheme.color33FFB3, width: 1.h),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(color: appTheme.color33FFB3, width: 1.h),
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaSelector(
    BuildContext context,
    MovieListProvider provider,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT CINEMA',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8.h,
              children: provider.cinemas.map((cinema) {
                final isSelected = provider.selectedCinema == cinema;
                return GestureDetector(
                  onTap: () => provider.selectCinema(cinema),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 24.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5C0612)
                          : appTheme.gray_900_03,
                      borderRadius: BorderRadius.circular(16.h),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0x33FFDF9E)
                            : appTheme.color19A48B,
                        width: 1.h,
                      ),
                    ),
                    child: Text(
                      cinema,
                      style: TextStyleHelper.instance.body14RegularBebasNeue
                          .copyWith(color: appTheme.gray_400, letterSpacing: 1),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, MovieListProvider provider) {
    return Padding(
      padding: EdgeInsets.only(left: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT DATE',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8.h,
              children: List.generate(provider.dates.length, (index) {
                final dateItem = provider.dates[index];
                final isSelected = provider.selectedDateIndex == index;
                return GestureDetector(
                  onTap: () => provider.selectDate(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5C0612)
                          : appTheme.gray_900_03,
                      borderRadius: BorderRadius.circular(12.h),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0x33FFDF9E)
                            : appTheme.color19A48B,
                        width: 1.h,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dateItem.dayLabel ?? '',
                          style: TextStyleHelper
                              .instance
                              .label10RegularBebasNeue
                              .copyWith(color: appTheme.gray_400),
                        ),
                        Text(
                          dateItem.dateNumber ?? '',
                          style:
                              TextStyleHelper.instance.title16RegularBodoniModa,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid(BuildContext context, MovieListProvider provider) {
    final movies = provider.filteredMovies;

    if (movies.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 32.h),
        child: Center(
          child: Text(
            provider.errorMessage ?? 'No movies found.',
            style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
              color: appTheme.gray_500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.h,
          mainAxisSpacing: 14.h,
          childAspectRatio: 0.58,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return MovieCardWidget(movie: movies[index]);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 32.h, bottom: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: SizedBox(
              width: 32.h,
              height: 32.h,
              child: CircularProgressIndicator(
                strokeWidth: 3.h,
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
                backgroundColor: appTheme.color33FFB3,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'LOADING MOVIES',
            style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
